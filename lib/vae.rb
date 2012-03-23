module Vae
  TIME_TYPES = %w(Full\ Time Part\ Time Temporary)

  QUESTION_TYPES = %w(Yes/No Multiple\ Choice Small\ Text\ Box Medium\ Text\ Box Month Year Label Date)

  ADMINS={
      :primary => {
          :name => "Rachel Yellin",
          :email => "ryellin@vaecorp.com",
          :title => "HR Recruiter"
      },
      :it => {
          :name => "Andy Kirk",
          :email => "akirk@vaecorp.com",
          :title => "Information Technology Manager"
      },
      :coo => {
          :name => "David Martin",
          :email => 'dmartin@vaecorp.com',
          :title => 'Chief Operating Officer'
      }
  }

  CORPORATE_ADDRESS = {
      'csi' => {
          :html => "<p>Conference Systems, Inc.<br />12910 Cloverleaf Center Drive<br />Suite 100<br />Germantown, MD 20874</p>",
          :plain => <<-ADDY
          Conference Systems, Inc.
        12910 Cloverleaf Center Drive
        Suite 100
        Germantown, MD 20874
          ADDY

      },
      :default => {
          :html => "<p>Visual Aids Electronics<br />12910 Cloverleaf Center Drive<br />Suite 100<br />Germantown, MD 20874</p>",
          :plain => <<-ADDY
          Visual Aids Electronics
        12910 Cloverleaf Center Drive
        Suite 100
        Germantown, MD 20874
          ADDY
      }}

  STATES = YAML::load_file(File.join(Rails.root, 'lib', 'states.yaml'))

end