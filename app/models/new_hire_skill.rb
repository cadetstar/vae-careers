class NewHireSkill < ActiveRecord::Base
  has_many :new_hire_request_skills, :dependent => :destroy
  has_many :new_hire_requests, :through => :new_hire_request_skills
end
