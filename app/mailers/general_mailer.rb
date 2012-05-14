class GeneralMailer < ActionMailer::Base
  default from: "careers@vaecorp.com"

  def welcome_email(applicant)
    @applicant = applicant
    mail(:to => "#{applicant.name_std} #{applicant.email}", :subject => "Welcome to VAE Careers!")
  end
end
