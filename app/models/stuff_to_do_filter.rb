class NextIssueFilter
  attr_accessor :users
  attr_accessor :priorities
  attr_accessor :statuses
  
  def initialize
    self.users = User.active
    self.priorities = get_priorites
    self.statuses = IssueStatus.find(:all)
  end
  
  def each
    { :users => self.users.sort,
      :priorities => self.priorities.sort,
      :statuses => self.statuses.sort}.each do |group, items|
      yield group, items
    end
  end

  private
  # Wrapper around Redmine's API since Enumerations changed in r2472
  def get_priorites
    if Enumeration.respond_to?(:priorities)
      return Enumeration.priorities
    else
      return Enumeration::get_values('IPRI')
    end
  end
end
