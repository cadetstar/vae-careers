ActionMailer::Base.smtp_settings = {
    :address => "mail.vaecorp.com",
    :port => 8889,
    :domain => "vaecorp.com",
    :authentication => :login,
    :user_name => "thankyou@vaecorp.com",
    :password => "V@3cs1IT"
}

Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
Mail.register_interceptor(ProductionMailInterceptor) if Rails.env.production?
