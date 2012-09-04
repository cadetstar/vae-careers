class GeneralMailer < ActionMailer::Base
  default from: "careers@vaecorp.com"
  add_template_helper(ApplicationHelper)

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

  def opening_mail(email_to, from, opening)
    @from = from
    @opening = opening

    mail(:to => email_to, :subject => I18n.t('opening_email.subject').gsub('%FROM%', @from.to_s))
  end
end
