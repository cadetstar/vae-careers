class Demographic < ActiveRecord::Base
  belongs_to :submission

  delegate :opening, :to => :submission

  scope :reports, joins(:submission => :opening)

  REPORT_FIELD_OVERRIDES = {
      'id' => false,
      'created_at' => false,
      'updated_at' => false,
      'opening' => true
  }

  OVERRIDE_METHOD = {

  }

end
