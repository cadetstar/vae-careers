class DynamicFormGroup < ActiveRecord::Base
  has_many :dynamic_file_group_links
  has_many :dynamic_files, :through => :dynamic_file_group_links

  has_many :dynamic_form_opening_links, :as => :owner
end
