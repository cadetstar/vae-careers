class Applicant < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :submissions
  has_many :openings, :through => :submissions
  has_many :applicant_files
  has_many :phones

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :first_name, :last_name, :preferred_name, :address_1, :address_2, :city, :state, :zip, :country, :home_phone, :cell_phone, :as => :applicant

  validates_format_of :email, :without => /@vaecorp\.com/, :message => "is invalid.  Employees should contact #{I18n.t('admins.primary.name')} to have their accounts set up."
  after_create :send_welcome_email

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

  private

  def send_welcome_email
    GeneralMailer.welcome_email(self).deliver
  end
end
