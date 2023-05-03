class RemoveViewAllStuffToDoReporteesOption < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :user_preferences, :stuff_to_do_view_all_reportees 
  end
  
  def self.down
    add_column :user_preferences, :stuff_to_do_view_all_reportees, :boolean, default: false
  end
end
