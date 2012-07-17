class GeneralMailer < ActionMailer::Base
  default from: "careers@vaecorp.com"

  def welcome_email(applicant)
    @applicant = applicant
    mail(:to => "#{applicant.name_std} #{applicant.email}", :subject => "Welcome to VAE Careers!")
  end

  def error_message(exception, trace, session, params, env, account, is_live = false, sent_on = Time.now)
    @exception = exception
    @trace = trace
    @session = session
    @params = params
    @env = env
    @account = account
    mail(:to => 'cadetstar@hotmail.com', :subject => "Error message: #{env['REQUEST_URI']}")
  end

  def central_mail(user_to, message, subject, url = nil)
    @message = message

    if url
      the_url = link_to eval(url, :only_path => false)
      @message.gsub!('%URL%', the_url)
    end

    mail(:to => user_to.email, :subject => subject)
  end
end
