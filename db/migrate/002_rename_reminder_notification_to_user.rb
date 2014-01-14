class RenameReminderNotificationToUser < ActiveRecord::Migration
  def up
    c = CustomField.find_by_name_and_type('reminder_subscription', 'UserCustomField').update('Ticket-reminder Subscription')
  end

  def down
    c = CustomField.find_by_name_and_type('Ticket-reminder Subscription', 'UserCustomField').update(name: 'reminder_subscription')
  end
end
