class StuffToDoController < ApplicationController
  def index
    @doing_now = NextIssue.doing_now(User.current)
    @recommended = NextIssue.recommended(User.current)
    @available = NextIssue.available(User.current)
  end
end
