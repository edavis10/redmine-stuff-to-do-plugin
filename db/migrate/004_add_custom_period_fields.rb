class AddCustomPeriodFields < ActiveRecord::Migration
  def self.up
    add_column :user_preferences, :custom_reminder_period_days, :integer
  end

  def self.down
    remove_column :user_preferences, :custom_reminder_period_days
  end
end