class Report < ActiveRecord::Base
  has_many :report_fields, :dependent => :destroy
  has_many :report_filters, :dependent => :destroy
  belongs_to :creator, :class_name => "RemoteUser"

  accepts_nested_attributes_for :report_fields, :allow_destroy => true
  accepts_nested_attributes_for :report_filters, :allow_destroy => true

  VALID_MODELS = {
      'Applicants' => Applicant,
      'Submissions' => Submission,
      'Demographics' => Demographic,
      'Submission_Answers' => SubmissionAnswer
  }

  VALIDATION_TYPES = {
      'Like' => 'like',
      'Begins with' => 'begins',
      'Ends with' => 'ends',
      'Contains' => 'like',
      'Exact match' => 'equal',
      'Like (case insensitive)' => 'lowerlike',
      'Begins with (case insensitive)' => 'lowerbegins',
      'Ends with (case insensitive)' => 'lowerends',
      'Exact match (case insensitive)' => 'lowerequal',
      'Greater Than' => 'greater',
      'After' => 'greater',
      'Less Than' => 'lesser',
      'Before' => 'lesser'
  }

  def purge_submissions(packed_params)
    unless self.operates_on == 'Submissions'
      return [0, 'This report does not operate on submissions.']
    else
      params = {}
      unless params.blank?
        begin
          params = JSON.parse(packed_params)
        rescue
          return [0, 'There was a problem attempting to purge the applicants.']
        end
      end

      puts "*************************"
      puts "*************************"
      puts "*************************"
      puts packed_params.inspect
      puts params.inspect
      puts "*************************"
      puts "*************************"
      puts "*************************"

      klass, results = self.retrieve_results(params)
      results.reject!{|r| r.completed_at ? (r.completed_at > 2.years.ago) : (r.created_at > 2.years.ago)}
      results.each do |r|
        r.destroy
      end
      return [results.size, nil]
    end
  end

  def retrieve_results(params = {})
    klass = VALID_MODELS[self.operates_on] || VALID_MODELS.values.first

    results = []

    run_times = 0
    self.report_filters.collect{|rf| rf.report_group}.uniq.sort.each do |rg|
      run_times += 1
      queryables = []
      assemblers = []
      selectables = []

      self.report_filters.where(:report_group => rg).each do |rf|
        method_name = klass::OVERRIDE_METHOD[rf.name] || rf.name
        if klass.column_names.include?(method_name)
          value = params[rf.id.to_s] || rf.value
          if rf.validation_type.match(/^lower/)
            method_name = "LOWER(#{method_name})"
            value = value.downcase
          end
          if (col = klass.columns.select{|c| c.name == method_name}.first)
            if col.type == :datetime
              begin
                parsed_value = Time.parse(value)
                value = parsed_value
              rescue
                # Do nothing
              end
            end
          end
          case rf.validation_type.gsub(/^lower/, '')
            when 'like'
              queryables << "#{method_name} like ?"
              assemblers << "%#{value}%"
            when 'begins'
              queryables << "#{method_name} like ?"
              assemblers << "#{value}%"
            when 'ends'
              queryables << "#{method_name} like ?"
              assemblers << "%#{value}"
            when 'equal'
              queryables << "#{method_name} = ?"
              assemblers << "#{value}"
            when 'greater'
              queryables << "#{method_name} > ?"
              assemblers << "#{value}"
            when 'lesser'
              queryables << "#{method_name} < ?"
              assemblers << "#{value}"
          end
        else
          selectables << [method_name, rf]
        end
      end
      puts ([queryables.join(" AND ")] + assemblers).inspect
      temp_results = klass.where([queryables.join(" AND ")] + assemblers).all
      puts temp_results.inspect
      unless selectables.empty?
        temp_results = temp_results.select do |tr|
          selectables.collect do |s|
            begin
              value = (params[s[1].id.to_s] || s[1].value)
              result = tr.try(s[0])
              if result.is_a? Time
                begin
                  parsed_value = Time.parse(value)
                  value = parsed_value
                rescue
                  # Do nothing
                end
              end
              case s[1].validation_type
                when 'greater'
                  value > result
                when 'lesser'
                  value < result
                else
                  r = Regexp.new case s[1].validation_type.gsub(/^lower/, '')
                                   when 'like'
                                     "#{value}"
                                   when 'begins'
                                     "^#{value}"
                                   when 'ends'
                                     "#{value}$"
                                   when 'equal'
                                     "^#{value}$"
                                 end, (s[1].validation_type.match(/^lower/) ? 'i' : nil)
                  result.to_s.match(r)
              end
            rescue
              false
            end
          end.reduce(:&)
        end
      end
      results += temp_results
    end
    if run_times > 1
      results.uniq!
    elsif run_times == 0
      results = klass.all
    end
    [klass, results]
  end

  def process(params = {})
    puts params.inspect
    filename = File.join(Rails.root, 'reports', self.id.to_s)
    completer = File.join(Rails.root, 'reports', 'completions', self.id.to_s)
    if File.exists?(completer)
      File.delete(completer)
    end

    klass, results = self.retrieve_results(params)

    if File.exists?(filename + '.xls')
      File.delete(filename + '.xls')
    end

    normal = Spreadsheet::Format.new(:size => 6)
    header = Spreadsheet::Format.new(:size => 8, :weight => :bold)


    f = File.open(filename + '.html', 'w')
    book = Spreadsheet::Workbook.new
    g = book.create_worksheet :name => "Results"

    g.default_format = normal
    g.row(0).default_format = header

    f.write("<table><tr>")
    self.report_fields.each_with_index do |rf, i|
      g[0, i] = if defined?(klass::OVERRIDE_NAMES)
                  klass::OVERRIDE_NAMES[rf.name] || rf.name.humanize
                else
                  rf.name.humanize
                end
      f.write("<th>#{g[0,i]}</th>")
    end
    f.write("</tr>")

    results.each_with_index do |entry, row|
      f.write("<tr>")
      self.report_fields.each_with_index do |rf, j|
        html_data = excel_data = data = entry.try(rf.name)
        if data.is_a? Array
          data = data.collect{|c| c.to_s}
          excel_data = data.join(10.chr)
          html_data = data.join('<br />')
        end
        g[row + 1, j] = excel_data
        f.write("<td>#{html_data}</td>")
      end
      f.write("</tr>")
    end
    f.write("</table>")
    f.close
    book.write(filename + '.xls')

    c = File.new(completer, 'w')
    c.puts params.to_json
    c.close
  end

  def _destroy
    false
  end
end
