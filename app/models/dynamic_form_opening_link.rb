class DynamicFormOpeningLink < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  belongs_to :opening
end
