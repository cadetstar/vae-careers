require 'uri'
class RemoteUserFailure < Devise::FailureApp
  def redirect_url
    "http://localhost:3000/return_to?username=#{params[:applicant][:email]}&password=#{params[:applicant][:password]}&return_to=#{URI.escape(from_accounts_path(:only_path => false), Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end