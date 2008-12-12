class NextIssue < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user
  acts_as_list
end
