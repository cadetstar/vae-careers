module Vae
  TIME_TYPES = %w(Full\ Time Part\ Time Temporary)

  QUESTION_TYPES = %w(Yes/No Multiple\ Choice Small\ Text\ Box Medium\ Text\ Box Month Year Label Date)

  STATES = YAML::load_file(File.join(Rails.root, 'lib', 'states.yaml'))

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

  RECRUITER_RECOMMENDATION = %w(Please\ Choose 1\ -\ Yes 2\ -\ Maybe 3\ -\ No)

  FORM_TOKENS = {
      '%FIRST_NAME%' => {:data => :first_name, :name => "First Name of Applicant"}
  }
end