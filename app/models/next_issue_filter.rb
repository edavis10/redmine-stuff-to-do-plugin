class NextIssueFilter
  attr_accessor :users
  attr_accessor :priorities
  attr_accessor :statuses
  
  def initialize
    self.users = User.active
    self.priorities = Enumeration::get_values('IPRI')
    self.statuses = IssueStatus.find(:all)
  end
  
  def each
    { :users => self.users,
      :priorities => self.priorities,
      :statuses => self.statuses}.each do |group, items|
      yield group, items
    end
  end
end
