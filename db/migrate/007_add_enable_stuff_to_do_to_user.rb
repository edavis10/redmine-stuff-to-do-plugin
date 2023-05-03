class AddEnableStuffToDoToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :user_preferences, :stuff_to_do_enabled, :boolean, default: true
  end
        
  def self.down
    remove_column :user_preferences, :stuff_to_do_enabled
  end
end
