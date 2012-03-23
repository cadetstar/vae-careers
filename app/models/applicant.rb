class Applicant < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :first_name, :last_name, :preferred_name, :address_1, :address_2, :city, :state, :zip, :country, :as => :applicant

  validates_format_of :email, :without => /@vaecorp\.com/, :message => "Employees should contact #{Vae::ADMINS[:primary]} to have their accounts set up."
end
