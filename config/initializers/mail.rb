ActionMailer::Base.smtp_settings = {

}

Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?