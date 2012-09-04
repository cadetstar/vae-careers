class GeneralMailer < ActionMailer::Base
  default from: "careers@vaecorp.com"
  add_template_helper(ApplicationHelper)

  def welcome_email(applicant)
    @applicant = applicant
    mail(:to => "#{applicant.name_std} #{applicant.email}", :subject => I18n.t('welcome_email.subject'))
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

  def application_confirmation(submission)
    @submission = submission

    mail(:to => submission.applicant.email, :subject => I18n.t('confirmatioN_email.subject'))
  end

  def recruiter_application(submission, remote_user)
    @submission = submission

    mail(:to => remote_user.email, :subject => 'An application has been received.')
  end

  def notify_email(email, subject, message)
    mail(:to => email, :subject => subject) do |format|
      format.html { render :text => message }
    end
  end

  def submission_add(ru, submission)
    @submission = submission
    @ru = ru

    mail(:to => ru.email, :subject => 'An application has been shared with you.')
  end

  def job_agents(todays, matches, ja)
    @todays = todays
    @matches = matches
    @ja = ja

    mail(:to => ja.applicant.email, :subject => I18n.t('job_agent.subject'))
  end
end
