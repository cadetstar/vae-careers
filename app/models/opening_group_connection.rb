class OpeningGroupConnection < ActiveRecord::Base
  belongs_to :opening
  belongs_to :question_group
end
