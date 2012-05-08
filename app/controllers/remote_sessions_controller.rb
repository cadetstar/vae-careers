class RemoteSessionsController < ApplicationController
  def from_accounts

    begin
      private_key = OpenSSL::PKey::RSA.new(File.read('lib/keys/acct_remote'))
      b = Base64.decode64(params[:key].gsub(' ','+'))
      key = private_key.private_decrypt(b)
      public_key = OpenSSL::PKey::RSA.new(File.read('lib/keys/remote_acct.pem'))
      encrypted_key = Base64.encode64(public_key.public_encrypt(key))

      uri = URI.parse("#{$accounts_location}/passkey/validate?id=#{params[:user]}&key=#{URI.escape(encrypted_key, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      user_info = JSON.parse(response.body)
      puts "**************************************"
      puts "**************************************"
      puts "**************************************"
      puts user_info.inspect
      puts "**************************************"
      puts "**************************************"
      puts "**************************************"
      remote_user = RemoteUser.find_or_create_by_email(user_info['email'])
      remote_user.update_attributes(user_info.select{|k,v| k != 'id' and (RemoteUser.attribute_names.include?(k) or k == 'roles')})

      session[:current_user] = remote_user.id
      redirect_to internal_user_path
    rescue
      flash[:alert] = 'I could not log you in with those credentials.'
      redirect_to new_applicant_session_path
    end

  end

  def universal_sign_out
    session[:current_user] = nil
    sign_out
    redirect_to root_path
  end


end