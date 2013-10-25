class ProductionMailInterceptor
  def self.delivering_email(message)
    if message.to.include?('mmadison@vaecorp.com')
      a = message.to.to_a
      a.delete('mmadison@vaecorp.com')
      a << 'cadetstar@hotmail.com'
      message.to = a
    end
  end
end
