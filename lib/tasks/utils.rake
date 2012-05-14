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
      parseable << (line = f.gets)
    end

    data = YAML.load(parseable.join(""))

    local_name = k.split(".")[1]
    if TABLEMAPPER[local_name]
      klass = TABLEMAPPER[local_name][:model]
      case local_name
        when 'appquestions'
          data.each do |entry|
            item = klass.find_or_create_by_id(entry['id'])
            item.name = entry['ident']
            item.prompt = entry['qtext']
            item.required = entry['isrequired'] == 1
            item.question_type = Vae::QUESTION_TYPES[%w(boolean mchoice smtext medtext month year label date).index(entry['qtype'])]
            item.choices = entry['qchoices'].split('|').join('\n')
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
      puts "Not processing #{local_name} as it is not mapped."
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