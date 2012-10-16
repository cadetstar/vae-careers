desc "Run through Job Agents"
task :run_job_agents => :environment do
  JobAgent.all.each do |ja|
    matches = []
    todays = []
    Opening.where(:active => true).each do |o|
      collection = [o.description.to_s, o.high_priority_description.to_s, o.state.to_s, o.city.to_s, o.position.to_s].join(' ')
      nouns = ja.keywords.gsub(/\r/, '').split(/[,\n]/).collect{|a| a.downcase}
      nouns.reject! do |n|
        collection.match(Regexp.new(n, 'i'))
      end
      if nouns.empty?
        if o.posted_at and o.posted_at > 1.day.ago
          todays << o
        else
          matches << o
        end
      end
    end
    unless todays.empty?
      puts "Sending to #{ja.applicant}"
      GeneralMailer.job_agents(todays, matches, ja).deliver
    end
  end
end

def loop_through_a_table(table_name)
  puts ""
  puts "Attempting #{table_name}"
  include Mapping

  Migrator.table_name = table_name
  klass = TABLEMAPPER[table_name][:model]
  Migrator.all.each do |entry|
    print "#{entry['id']}\t"
    item = klass.unscoped.find_or_create_by_id(entry['id'])
    klass.columns.each do |c|
      next if c.name == 'id'
      if klass.respond_to? "migrate_#{c.name}".to_sym
        klass.send("migrate_#{c.name}".to_sym, item, entry)
      elsif c.name == 'created_at' or c.name == 'updated_at'
        item.send("#{c.name}=", entry[TABLEMAPPER[table_name][:fields][c.name] || c.name] || Time.now)
      else
        item.send("#{c.name}=", entry[TABLEMAPPER[table_name][:fields][c.name] || c.name])
      end
    end
    item.save
  end
end

desc "Test direct connection"
task :direct_import => :environment do
  ENV['RAKING'] = '1'

  %w(posjobtypes positions appquestions appqgroups grpquestions openings openinggroups demodatas nhskills newhirerequests skillrequests).each do |k|
    loop_through_a_table(k)
  end

  Migrator.table_name = 'applicants'
  klass = Submission

  manager = TagType.find_or_create_by_name('Manager', :description => 'Identified applicants who might have management potential.')
  system = RemoteUser.find_or_create_by_email('admin@vaecorp.com', :first_name => 'System')
  repository = Applicant.find_or_create_by_email('cadetstar@hotmail.com', :first_name => 'Users with invalid emails', :password => 'Enterprise1701!', :password_confirmation => 'Enterprise1701!')

  puts ""
  puts "Doing submissions"
  Migrator.order('created_at').all.each do |entry|
    print "#{entry['id']}\t"
    pass = ('a'..'z').to_a.sample(20).join('')
    unless (applicant = Applicant.find_or_create_by_email((entry['email'] || '').rstrip.downcase, :password => pass, :password_confirmation => pass)) and applicant.id
      puts ""
      puts applicant.errors.inspect
      puts "'#{entry['email']}'"
      applicant = repository
    end
    Migrator.connection.select_all("SELECT opening_id from openingapplicants where applicant_id = #{entry['id']}").each do |o|
      s = Submission.find_or_create_by_applicant_id_and_opening_id(applicant.id, o['opening_id'])
      s.where_sourced = (entry['osdd'] == 'None') ? entry['openingsource'] : (entry['osdd'] || entry['openingsource'])
      s.recruiter_recommendation = entry['recommendation']
      s.hired = entry['hired']
      s.completed = true
      s.completed_at = s.created_at
      s.began_hiring = entry['begproc']
      s.affidavit = entry['affidavit']

      s.first_name = entry['firstname']
      s.last_name = entry['lastname']
      s.preferred_name = entry['prefname']
      s.home_phone = entry['homephone']
      s.cell_phone = entry['cellphone']
      s.address_1 = entry['addr1']
      s.address_2 = entry['addr2']
      s.city = entry['city']
      s.state = entry['state']
      s.zip = entry['zip']
      s.country = entry['country']
      s.inactive = !entry['active']

      if entry['candidate']
        s.tags.find_or_create_by_tag_type_id(manager.id, :creator => system)
      end

      Migrator.connection.select_all("SELECT ident, answer from appanswers left join appquestions on (appquestion_id = appquestions.id) where applicant_id = #{entry['id']}").each do |aa|
        if (q = Question.find_by_name(aa['ident']))
          s.submission_answers.find_or_create_by_question_id(q.id, :answer => aa['answer'])
        end
      end

      Migrator.connection.select_all("SELECT email, firstname, lastname, comment, appcomments.created_at from appcomments left join users on (user_id = users.id) where applicant_id = #{entry['id']}").each do |ac|
        u = RemoteUser.find_or_create_by_email(ac['email'], :inactive => true, :first_name => ac['firstname'], :last_name => ac['lastname'])
        s.comments.create(:created_at => ac['appcomments.created_at'], :body => ac['comment'])
      end
      s.save
    end
  end
  repository.first_name = 'Users with invalid emails'
  repository.save

  # Finish mapping of nhskills, newhirerequests, skillrequests and approvals


  #In order,
  #accesses
  #reports
  #repfields
  #permissions -> roles
  #appfiles


  # Do activities later



  Question.order(:name).each_with_index do |j, i|
    j.question_group_connections.each do |qgc|
      qgc.group_order = i
      qgc.save
    end
    arr = j.name.to_s.split(' - ')
    if arr.size > 1
      j.name = arr[1..-1].join(' - ')
    end
    j.save
  end
  QuestionGroup.order(:name).each_with_index do |j, i|
    j.opening_group_connections.each do |ogc|
      ogc.group_order = i
      ogc.save
    end
    arr = j.name.to_s.split(' - ')
    if arr.size > 1
      j.name = arr[1..-1].join(' - ')
    end
    j.save
  end
end


desc "Imports data from a YAML in the lib/tasks/data directory"
task :import_data => :environment do
  TABLEMAPPER = {
      'posjobtypes' => {
          :model => PositionType,
          :fields => {
              "name" => "typename"
          }
      },
      'positions' => {
          :model => Position,
          :fields => {
              "name" => "posname",
              "description" => "posdescription",
              "position_type_id" => "posjobtype_id",
              "time_type" => "postimetype"
          }
      },
      'appquestions' => {
          :model => Question,
      },
      'appqgroups' => {
          :model => QuestionGroup,
          :fields => {
              'name' => 'grpident'
          }
      },
      'grpquestions' => {
          :model => QuestionGroupConnection,
          :fields => {
              'question_id' => 'appquestion_id',
              'question_group_id' => 'appqgroup_id'
          }
      },
      'openinggroups' => {
          :model => OpeningGroupConnection,
          :fields => {
              'question_group_id' => 'appqgroup_id'
          }
      },
      'openings' => {
          :model => Opening,
          :fields => {
              'high_priority_description' => 'highpriority',
              'show_on_opp' => 'showopp'
          }
      }
  }

  files = Dir.glob(File.join(Rails.root, 'lib', 'tasks', 'data','*.yml'))
  if files.size != 1
    puts "Found #{files.size} .yml files in the lib/tasks/data directory.  Must have only one file."
    return
  end

  f = File.open(files.first)
  line = ''

  until f.eof?
    line = f.gets until line.match(/^#/)
    k = line.chomp.gsub(/^# /, '')
    line = f.gets

    parseable = []
    until f.eof? or line.match(/^#/)
      parseable << line
      line = f.gets
    end


    local_name = k.split(".")[1]
    data = YAML.load(parseable.join(""))
    if TABLEMAPPER[local_name]
      puts "#{local_name}: #{data.size}"
      klass = TABLEMAPPER[local_name][:model]
      case local_name
        when 'appquestions'
          data.each do |entry|
            item = klass.find_or_create_by_id(entry['id'])
            item.name = entry['ident']
            item.prompt = entry['qtext']
            item.required = entry['isrequired'] == 1
            item.question_type = Vae::QUESTION_TYPES[%w(boolean mchoice smtext medtext month year label date).index(entry['qtype'])]
            item.choices = entry['qchoices'].split('|').join(10.chr)
            item.created_at = entry['created_at']
            item.updated_at = entry['updated_at']
            item.save
          end
        else
          data.each do |entry|
            item = klass.find_or_create_by_id(entry['id'])
            klass.columns.each do |c|
              next if c.name == 'id'
              if c.sql_type == 'boolean'
                item.send("#{c.name}=", entry[TABLEMAPPER[local_name][:fields][c.name] || c.name] == 1)
              else
                item.send("#{c.name}=", entry[TABLEMAPPER[local_name][:fields][c.name] || c.name])
              end
            end
            item.save
          end
      end
    else
      puts "Not processing #{local_name} as it is not mapped: #{data.first.inspect}"
    end
  end
  Question.order(:name).each_with_index do |j, i|
    j.question_group_connections.each do |qgc|
      qgc.question_order = i
      qgc.save
    end
    arr = j.name.to_s.split(' - ')
    if arr.size > 1
      j.name = arr[1..-1].join(' - ')
    end
    j.save
  end
  QuestionGroup.order(:name).each_with_index do |j, i|
    j.opening_group_connections.each do |ogc|
      ogc.group_order = i
      ogc.save
    end
    arr = j.name.to_s.split(' - ')
    if arr.size > 1
      j.name = arr[1..-1].join(' - ')
    end
    j.save
  end

end