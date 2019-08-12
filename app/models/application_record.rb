# ActiveRecord models will now inherit from ApplicationRecord by default instead of ActiveRecord::Base.
# You should create an application_record.rb file under app/models with:
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
