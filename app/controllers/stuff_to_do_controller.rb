class StuffToDoController < ApplicationController
  def index
    @doing_now = NextIssue.doing_now(User.current)
    @recommended = NextIssue.recommended(User.current)
  end
end
