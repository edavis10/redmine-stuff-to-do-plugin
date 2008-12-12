class StuffToDoController < ApplicationController
  def index
    @doing_now = NextIssue.find(:all,
                                :conditions => ['user_id = ?', User.current.id],
                                :limit => 5,
                                :order => 'position ASC')
  end
end
