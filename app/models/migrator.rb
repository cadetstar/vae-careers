class Migrator < ActiveRecord::Base
  self.establish_connection :old

end