class NewHireRequestSkill < ActiveRecord::Base
  belongs_to :new_hire_request
  belongs_to :new_hire_skill
end
