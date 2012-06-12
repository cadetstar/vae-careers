class DynamicFileGroupLink < ActiveRecord::Base
  belongs_to :dynamic_file
  belongs_to :dynamic_form_group
end
