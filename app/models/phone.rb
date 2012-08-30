class Phone < ActiveRecord::Base
  belongs_to :applicant

  def to_s
    data.to_s
  end
end
