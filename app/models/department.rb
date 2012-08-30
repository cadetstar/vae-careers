require 'net/http'
class Department < ActiveRecord::Base
  belongs_to :manager, :class_name => 'RemoteUser'
  belongs_to :supervisor, :class_name => 'RemoteUser'
  belongs_to :supervising_department, :class_name => 'Department'

  has_many :remote_user_departments
  has_many :remote_users, :through => :remote_user_departments

  has_many :openings

  def self.list_for_select(user = nil)
    if user and !user.administrator?
      user.departments.order("code").all
    else
      Department.order("code").all
    end.collect{|d| [d, d.id]}
  end

  def self.states_with_departments
    Department.select("distinct departments.state").order("departments.state").where(["state not in (?)", ['USA', 'CAN']]).all.collect{|c| c.state}
  end

  def city_state
    [city, state].compact.join(', ')
  end

  def to_s
    [code, name].compact.join(' - ')
  end

  def fetch_from_accounts
    begin
      public_key = OpenSSL::PKey::RSA.new(File.read('lib/keys/remote_acct.pem'))
      encrypted_key = Base64.encode64(public_key.public_encrypt(Time.now.at_beginning_of_day.to_i.to_s))

      uri = URI.parse("#{$accounts_location}/departments/remote?key=#{URI.escape(encrypted_key, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      batch_info = JSON.parse(response.body)
      user_info = batch_info['users']

      user_info.each do |u|
        remote_user = RemoteUser.find_or_create_by_email(u['email'])
        remote_user.update_attributes(u.select{|k,v| k != 'id' and (RemoteUser.attribute_names.include?(k) or k == 'roles')})
      end

      department_info = batch_info['departments']

      department_info.each do |d|
        dept = Department.find_or_create_by_code(d[0])
        dept.name = d[1]
        dept.city = d[2]
        dept.state = d[3]
        dept.supervising_department = Department.find_by_code(d[4])
        dept.manager = RemoteUser.find_by_email(d[5])
        dept.supervisor = RemoteUser.find_by_email(d[6])
        dept.classification = d[7]
        dept.short_name = d[8]
        dept.save
      end
    rescue Exception => e
      puts e.inspect
      puts e.backtrace
    end
  end
end
