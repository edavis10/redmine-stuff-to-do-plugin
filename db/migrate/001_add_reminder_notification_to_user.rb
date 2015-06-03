class AddReminderNotificationToUser < ActiveRecord::Migration
  def self.up
    c = CustomField.create({:name => 'reminder_subscription', :field_format => 'bool', :editable => true})
    c.type = 'UserCustomField'
    c.save
  end

  def self.down
    CustomField.find_by_name_and_type('reminder_subscription', 'UserCustomField').delete
  end
end
