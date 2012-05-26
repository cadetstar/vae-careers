class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "[Original: #{message.to}] #{message.subject}"
    message.to = "cadetstar@hotmail.com"
  end
end