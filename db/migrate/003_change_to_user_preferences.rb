class ChangeToUserPreferences < ActiveRecord::Migration
  def self.up
    CustomField.find_by_name_and_type('Ticket-reminder Subscription', 'UserCustomField').destroy
    add_column :user_preferences, :subscribe_to_reminder, :boolean, :default => false
  end

  def self.down
    c = CustomField.create({:name => 'Ticket-reminder Subscription', :field_format => 'bool', :editable => true})
    c.type = 'UserCustomField'
    c.save
    remove_column :user_preferences, :subscribe_to_reminder
  end
end