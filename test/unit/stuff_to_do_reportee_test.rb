require File.expand_path('../../test_helper', __FILE__)

class StuffToDoReporteeTest < ActiveSupport::TestCase
  fixtures :users, :stuff_to_do_reportees, :groups_users
  
  def setup
    @manager = User.find(4)
    @manager2 = User.find(2)
    @reportee = User.find(5)
  end

  def test_create
    initial_size = StuffToDoReportee.count    
    reportee = StuffToDoReportee.new(:user => @manager, :reportee => @reportee)
    assert_equal @manager, reportee.user, "initial user"
    assert_equal @reportee, reportee.reportee, "initial reportee"
    assert reportee.save
    assert_equal initial_size + 1, StuffToDoReportee.count, "size after create"
      
    duplicate_reportee = StuffToDoReportee.new(:user => @manager, :reportee => @reportee)
    assert !duplicate_reportee.save
    
    assert !StuffToDoReportee.new(:user => nil, :reportee => @reportee).save
    assert !StuffToDoReportee.new(:user => @manager, :reportee => nil).save
    assert !StuffToDoReportee.new(:user => @manager, :reportee => @user).save

  end
  
  def test_find_reportees
    reportees = StuffToDoReportee.reportees_for(@manager)
    assert_equal 2, reportees.size
    
    reportees = StuffToDoReportee.reportees_for(@manager2)
    assert_equal 1, reportees.size
    
    assert_equal (User.active - StuffToDoReportee.reportees_for(@manager) - [@manager]).count, StuffToDoReportee.available_reportees_for(@manager).count
  end
  
  def test_groups
    group = Group.first;
    initial_size = StuffToDoReportee.reportees_for(@manager2).count

    assert StuffToDoReportee.new(:user => @manager2, :group => group).save
    assert_equal 1, StuffToDoReportee.groups_for(@manager2).count, "group added"
    assert_equal initial_size + group.users.count, StuffToDoReportee.reportees_for(@manager2).count, "add members of a group,  do not add members repeatedly"
    
    assert_equal (Group.active - StuffToDoReportee.groups_for(@manager2)).count, StuffToDoReportee.available_groups_for(@manager2).count
    assert_equal (User.active - StuffToDoReportee.reportees_for(@manager2) - [@manager2]).count, StuffToDoReportee.available_reportees_for(@manager2).count
      
    assert !StuffToDoReportee.new(:user => @manager2, :reportee =>  group.users.last).save
    assert !StuffToDoReportee.new(:user => @manager2, :group => group).save
  end
  
end
