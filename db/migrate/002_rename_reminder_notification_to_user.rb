class RenameReminderNotificationToUser < ActiveRecord::Migration
  def up
    c = CustomField.find_by_name_and_type('reminder_subscription', 'UserCustomField')
    c.name = 'Ticket-reminder Subscription'
    c.save
  end

  def down
    c = CustomField.find_by_name_and_type('Ticket-reminder Subscription', 'UserCustomField')
    c.name = 'reminder_subscription'
    c.save
  end
end
