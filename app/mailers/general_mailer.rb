class GeneralMailer < ActionMailer::Base
  default from: "careers@vaecorp.com"

  def welcome_email(applicant)
    @applicant = applicant
    mail(:to => "#{applicant.name_std} #{user.email}", :subject => "Welcome to VAE Careers!")
  end

  def error_message(exception, trace, session, params, env, account, is_live = false, sent_on = Time.now)
    @recipients    = 'cadetstar@hotmail.com'
    @from          = 'Careers System <careers@vaecorp.com>'
    @subject       = "Error message: #{env['REQUEST_URI']}"
    @sent_on       = sent_on
    @content_type = "text/html"
    @exception = exception
    @trace = trace
    @session = session
    @params = params
    @env = env
    @account = account
  end
end
