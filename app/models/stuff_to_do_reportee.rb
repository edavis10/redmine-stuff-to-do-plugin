class StuffToDoReportee < ActiveRecord::Base
  unloadable

  belongs_to :user
  belongs_to :reportee, :class_name => 'User'
  belongs_to :group
  
  validates_presence_of :user
  validate :validate_reportee_or_group, :validate_reportee, :validate_group
  
  def self.reportees_for(user)
      
      reportees = user.pref[:stuff_to_do_view_all_reportees] ? User.active : user_reportees_for(user) | reportees_from_groups_for(user)
      return reportees
  end
  
  def self.user_reportees_for(user)
    reportees = []
    StuffToDoReportee.where(:user_id => user.id).each do |rep|
      reportees << rep.reportee unless rep.reportee.nil?
    end
    return reportees    
  end
  
  def self.groups_for(user)
    groups = []
    StuffToDoReportee.where(:user_id => user.id).each do |rep|
      groups << rep.group unless rep.group.nil?
    end
    return groups
  end
  
  def self.reportees_from_groups_for(user)
    reportees = []
    groups_for(user).each do |group|
      reportees |= group.users
    end
    return reportees
  end
  
  def self.available_reportees_for(user)
    return User.active - reportees_for(user) - [user]
  end
  
  def self.available_groups_for(user)
    return Group.active - groups_for(user)
  end
  
  
  def validate_reportee_or_group
    errors.add(:reportee, :nil) if reportee.nil? && group.nil?    
  end
  
  def validate_reportee
    errors.add(:reportee, :equals_user) if !reportee.nil? && (reportee == user)
    errors.add(:reportee, :reportee_not_unique) if !user.nil? && !reportee.nil? && StuffToDoReportee.where(:user_id => user.id, :reportee_id => reportee.id).count > 0
    
    if !reportee.nil? && !user.nil?
      StuffToDoReportee.groups_for(user).each do |group|
        if group.users.include?(reportee)
          errors.add(:reportee, :reportee_included_in_group)
        end
      end
    end  
  end
  
  def validate_group
    errors.add(:group, :group_not_unique) if !user.nil? && !group.nil? && StuffToDoReportee.where(:user_id => user.id, :group_id => group.id).count > 0 
  end
  
end