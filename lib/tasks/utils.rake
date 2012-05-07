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
  lines = f.readlines

  parseables = {}
  data = {}

  lines.shift until lines[0].match(/^#/)

  until lines.empty?
    k = lines[0].chomp.gsub(/^# /, '')
    lines.shift
    parseables[k] = []
    until lines.empty? or lines[0].match(/^#/)
      parseables[k] << lines.shift
    end
    data[k] = YAML.load(parseables[k].join(""))
  end

  data.keys.each do |k|
    local_name = k.split(".")[1]
    klass = TABLEMAPPER[local_name][:model]
    case local_name
      when 'appquestions'
        data[k].each do |line|
          item = klass.find_or_create_by_id(line['id'])
          item.name = line['ident']
          item.prompt = line['qtext']
          item.required = line['isrequired'] == 1
          item.question_type = Vae::QUESTION_TYPES[%w(boolean mchoice smtext medtext month year label date).index(line['qtype'])]
          item.choices = line['qchoices'].split('|').join('\n')
          item.created_at = line['created_at']
          item.updated_at = line['updated_at']
          item.save
        end
      else
        data[k].each do |line|
          item = klass.find_or_create_by_id(line['id'])
          klass.columns.each do |c|
            next if c.name == 'id'
            if c.sql_type == 'boolean'
              item.send("#{c.name}=", line[TABLEMAPPER[local_name][:fields][c.name] || c.name] == 1)
            else
              item.send("#{c.name}=", line[TABLEMAPPER[local_name][:fields][c.name] || c.name])
            end
          end
          item.save
        end
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