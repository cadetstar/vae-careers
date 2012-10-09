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

  def self.migrate_veteran(item, entry)
    if (entry['isdisabledvet'].to_i + entry['isbadgevet'].to_i + entry['is12985vet'].to_i + entry['issepvet'].to_i) > 0
      item.veteran = true
    elsif entry['isnotvet'].to_i == 1
      item.veteran = false
    end
  end
end
