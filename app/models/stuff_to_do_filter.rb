class StuffToDoFilter
  attr_accessor :users
  attr_accessor :priorities
  attr_accessor :statuses
  
  def initialize(params = {})
    self.users = [params[:user]]
    self.priorities = get_priorites
    self.statuses = IssueStatus.where(:is_closed => false)
  end
  
  def each
    if StuffToDo.using_issues_as_items?
      {
        :users => self.users,
        :priorities => self.priorities.sort,
        :statuses => self.statuses.sort
      }.each do |group, items|
        yield group, items
      end
    end

    # Finally projects
    yield :projects if StuffToDo.using_projects_as_items?
  end

  private
  # Wrapper around Redmine's API since Enumerations changed in r2472
  def get_priorites
    RedmineStuffToDo::StuffToDoCompatibility::IssuePriority.all
  end
end
