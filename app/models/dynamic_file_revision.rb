require 'fileutils'
class DynamicFileRevision < ActiveRecord::Base
  belongs_to :dynamic_file

  has_many :file_fields, :order => :field_name

  mount_uploader :dynamic_file_store, DynamicFileUploader
  attr_accessor :cached_values

  after_commit :initialize_fields_and_test_combine, :on => :create

  def initialize_fields_and_test_combine
    output = `pdftk #{File.join(Rails.root.to_s, 'lib', 'blank.pdf')} #{self.dynamic_file_store.current_path} cat output #{File.join(Rails.root.to_s, 'tmp', 'test.pdf')}`; result=$?.success?
    unless result
      self.can_be_compiled = false
    else
      self.can_be_compiled = true

      fields = `pdftk "#{self.dynamic_file_store.current_path}" dump_data_fields`
      fields.split('---').each do |field|
        if (k = field.match(/FieldName: (.+?)\n/))
          name = k[1]
          self.file_fields.create(:field_name => name)
        end
      end
    end
    self.save
  end

  def generate_file_with_form(applicant = nil, destination = "tmp/#{Time.now.to_i}.pdf")
    data = {}
    self.file_fields.each do |ff|
      data[ff.field_name] = parse_data_field(ff.system_data, applicant)
    end
    fdf = PdfForms::Fdf.new data
    loc = Tempfile.new('pdf-form-data.fdf')
    loc.close
    fdf.save_to loc.path
    if data.empty?
      FileUtils.cp(self.dynamic_file_store.current_path, destination)
    else
      begin
        `pdftk "#{self.dynamic_file_store.current_path}" fill_form "#{loc.path}" output "#{destination}"`
      rescue
        retry
      end
    end
    destination
  end

  def parse_data_field(text, applicant)
    return "(BLANK)" if text.blank? and applicant.nil?
    Vae::FORM_TOKENS.each do |k,v|
      if text
        if applicant
          cached_values[v[:data]] ||= applicant.send(v[:data])
          text.gsub!(k, cached_values[v[:data]])
        else
          text.gsub!(k, v[:name])
        end
      end
    end
    text
  end
end
