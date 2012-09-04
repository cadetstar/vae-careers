class Demographic < ActiveRecord::Base
  belongs_to :submission
  belongs_to :opening

  scope :reports, joins(:submission => :opening)

  REPORT_FIELD_OVERRIDES = {
      'id' => false,
      'created_at' => false,
      'updated_at' => false,
      'opening' => true
  }

  OVERRIDE_METHOD = {

  }
  after_create :set_opening

  def set_opening
    self.opening = self.submission.try(:opening)
    self.save
  end
end
