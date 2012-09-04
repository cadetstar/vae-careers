class Applicant < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :submissions
  has_many :openings, :through => :submissions
  has_many :applicant_files
  has_many :phones
  has_many :comments, :as => :owner
  has_many :tags, :as => :owner, :dependent => :destroy
  has_many :tag_types, :through => :tags


  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :first_name, :last_name, :preferred_name, :address_1, :address_2, :city, :state, :zip, :country, :home_phone, :cell_phone, :as => :applicant

  validates_format_of :email, :without => /@vaecorp\.com/, :message => "is invalid.  Employees should contact #{I18n.t('admins.primary.name')} to have their accounts set up."
  after_create :send_welcome_email

  REPORT_FIELD_OVERRIDES = {
      "id" => false,
      "updated_at" => false,
      "submissions" => true,
      "openings" => true,
      "phones" => true,
      'home_phone' => true,
      'cell_phone' => true,
      'name_std' => true,
      'name_lnf' => true,
      'city_state' => true,
      'reset_password_token' => false,
      'reset_password_sent_at' => false,
      'remember_created_at' => false,
      'encrypted_password' => false,
      'tags' => true
  }

  OVERRIDE_METHOD = {
  }

  GROUPED_OPTIONS = %w(submissions openings)

  scope :reports, joins(:submissions, :openings, "LEFT JOIN phones pc ON (pc.applicant_id = applicants.id AND pc.phone_type = 'cell')", "LEFT JOIN phones ph ON (ph.applicant_id = applicants.id AND ph.phone_type = 'home')")

  def name_std
    [first_name, last_name].select{|c| !c.blank?}.join(" ")
  end

  def name_lnf
    [last_name, first_name].select{|c| !c.blank?}.join(", ")
  end

  def city_state
    [city, state].compact.join(", ")
  end

  def to_s
    name_std
  end

  def home_phone
    self.phones.find_or_create_by_phone_type('home').data
  end

  def home_phone=(val)
    hp = self.phones.find_or_create_by_phone_type('home')
    hp.data = val
    hp.save
  end

  def cell_phone
    self.phones.find_or_create_by_phone_type('cell').data
  end

  def cell_phone=(val)
    cp = self.phones.find_or_create_by_phone_type('cell')
    cp.data = val
    cp.save
  end

  def self.indexed_attributes
    %w(email first_name last_name preferred_name city state zip country tags current_sign_in_at last_sign_in_at sign_in_count)
  end

  private

  def send_welcome_email
    GeneralMailer.welcome_email(self).deliver
  end
end
