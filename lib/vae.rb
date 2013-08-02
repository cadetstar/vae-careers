module Vae
  TIME_TYPES = {
      'Full Time' => 'FT',
      'Part Time' => 'PT',
      'Temporary' => 'TEMP'
  }

  QUESTION_TYPES = %w(Yes/No Multiple\ Choice Small\ Text\ Box Medium\ Text\ Box Month Year Label Date)

  STATES = YAML::load_file(File.join(Rails.root, 'lib', 'states.yaml'))

  SUBMISSIONS = {
      'genders' => %w(Male Female),
      'races' => %w(White Black\ or\ African\ American Hispanic\ or\ Latino Asian American\ Indian\ or\ Alaska\ Native Native\ Hawaiian\ or\ Pacific\ Islander Two\ or\ More\ Races),
      'veteran' => %w(Yes No)
  }

  SOURCES = {
      'CareerBuilder' => 'CareerBuilder',
      'Monster' => 'Monster',
      'CraigsList' => 'CraigsList',
      'JobsAV' => 'JobsAV',
      'InfoComm' => 'InfoComm',
      'MySpace' => 'MySpace',
      'Facebook' => 'Facebook',
      'State Website' => 'State Website',
      'VAE Careers' => 'VAE Careers',
      'Employee Referral' => 'Employee Referral',
      'Military Stars' => 'Military Stars',
      'Newspaper or Magazine' => 'Newspaper/Magazine',
      'School or Community' => 'School/Community',
      'On-Line Newspaper or Magazine' => 'On-Line Newspaper/Magazine Ad',
      'Job Fair' => 'Job Fair',
      'Indeed' => 'Indeed',
      'Other' => 'Other (please explain below)'
  }

  POSTING_OPTIONS = [
      "Do Not Post - Internal Candidate has been identified to fill the position.",
      "Post on Careers Site Only - External Candidate has been identified; no advertising necessary.",
      "Post & Advertise"
  ]

  RECRUITER_RECOMMENDATION = %w(Please\ Choose 1\ -\ Yes 2\ -\ Maybe 3\ -\ No)

  FORM_TOKENS = {
      '%FIRST_NAME%'      => {:data => :first_name,       :name => 'First Name'},
      '%LAST_NAME%'       => {:data => :last_name,        :name => 'Last Name'},
      '%ADDRESS1%'        => {:data => :address_1,        :name => 'Address Line 1'},
      '%ADDRESS2%'        => {:data => :address_2,        :name => 'Address Line 2'},
      '%CITY%'            => {:data => :city,             :name => 'City'},
      '%STATE%'           => {:data => :state,            :name => 'State'},
      '%COUNTRY%'         => {:data => :country,          :name => 'Country'},
      '%CELL_PHONE%'      => {:data => :cell_phone,       :name => 'Cell Phone'},
      '%HOME_PHONE%'      => {:data => :home_phone,       :name => 'Home Phone'},
      '%HOME_OR_CELL%'    => {:data => :home_or_cell,     :name => 'Home or Cell Phone (if home phone is blank)'},
      '%CITY_STATE%'      => {:data => :city_state,       :name => 'City, State'},
      '%EMAIL%'           => {:data => :email,            :name => 'Email Address'},
      '%NAME_LNF%'        => {:data => :name_lnf,         :name => 'Name (Last Name First)'},
      '%NAME_STD%'        => {:data => :name_std,         :name => 'Name (First Name Last Name)'},
      '%PREFERRED_NAME%'  => {:data => :preferred_name,   :name => 'Preferred Name'},
      '%ZIP%'             => {:data => :zip,              :name => 'Zip Code'},
      '%CSZ%'             => {:data => :csz,              :name => 'City State and Zip'},
      '%COMBINED_ADDR%'   => {:data => :combined_address, :name => 'Combined Address Lines'},
      '%FULL_ADDRESS%'    => {:data => :full_address,     :name => 'Full Address with City, State and Zip'}
  }
end