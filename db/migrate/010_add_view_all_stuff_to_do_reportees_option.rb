class AddViewAllStuffToDoReporteesOption < ActiveRecord::Migration[4.2]
  def self.up
     add_column :user_preferences, :stuff_to_do_view_all_reportees, :boolean, default: false
  end
  
  def self.down
    remove_column :user_preferences, :stuff_to_do_view_all_reportees
  end
end
