class AddEnableStuffToDoToUser < ActiveRecord::Migration
  def self.up
     add_column :user_preferences, :stuff_to_do_enabled, :boolean, :default => false
  end
  
  def self.down
    remove_column :user_preferences, :stuff_to_do_enabled
  end
end