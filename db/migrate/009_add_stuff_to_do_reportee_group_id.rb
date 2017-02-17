class AddStuffToDoReporteeGroupId  < ActiveRecord::Migration
  def self.up 
      add_column :stuff_to_do_reportees, :group_id, :integer
  end
  
  def self.down
    drop_column :stuff_to_do_reportees, :group_id
  end
end