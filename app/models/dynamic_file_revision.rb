class DynamicFileRevision < ActiveRecord::Base
  belongs_to :dynamic_file

  has_many :file_fields

  mount_uploader :dynamic_file_store, DynamicFileUploader

  after_create :initialize_fields_and_test_combine

  def initialize_fields_and_test_combine
    result = `pdftk #{File.join(Rails.root.to_s, 'lib', 'blank.pdf')} #{File.join(Rails.root.to_s, self.dynamic_file_store)} cat output #{File.join(Rails.root.to_s, 'tmp', 'test.pdf')}`
    if result =~ /Errors/
      self.can_be_compiled = false
    else
      self.can_be_compiled = true

      fields = `pdftk #{File.join(Rails.root.to_s, self.dynamic_file_store)} dump_data_fields`
      fields.split('---').each do |field|
        if (k = field.match(/FieldName: (.+?)\n/))
          name = k[1]
          self.file_fields.create(:field_name => name)
        end
      end
    end
    self.save
  end
end
