class DynamicFormOpeningLink < ActiveRecord::Base
  belongs_to :file, :polymorphic => true
  belongs_to :opening

  belongs_to :pre_dynamic_file, :conditions => ['file_type = ? and form_type = ?', 'DynamicFile', 'pre'], :foreign_key => :file_id, :class_name => 'DynamicFile'
  belongs_to :pre_dynamic_form_group, :conditions => ['file_type = ? and form_type = ?', 'DynamicFormGroup', 'pre'], :foreign_key => :file_id, :class_name => 'DynamicFormGroup'

  belongs_to :post_dynamic_file, :conditions => ['file_type = ? and form_type = ?', 'DynamicFile', 'post'], :foreign_key => :file_id, :class_name => 'DynamicFile'
  belongs_to :post_dynamic_form_group, :conditions => ['file_type = ? and form_type = ?', 'DynamicFormGroup', 'post'], :foreign_key => :file_id, :class_name => 'DynamicFormGroup'
end
