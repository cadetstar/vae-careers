require 'uri'
class RemoteUserFailure < Devise::FailureApp
  def redirect_url
    if params[:applicant] and params[:applicant][:email].match(/(vaecorp|conferencesystems)\.com/i)
      "#{$accounts_location}/return_to?type=sign_in&username=#{params[:applicant] and params[:applicant][:email]}&password=#{params[:applicant] and params[:applicant][:password]}&return_to=#{URI.escape(from_accounts_path(:only_path => false), Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
    else
      new_applicant_session_path
    end
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
