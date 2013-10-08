class AddEscalationNotificationToUser < ActiveRecord::Migration
  def self.up
    c = CustomField.create({:name => 'Wiedervorlage', :field_format => 'bool', :editable => true})
    c.type = 'UserCustomField'
    c.save
  end

  def self.down
    CustomField.find_by_name_and_type('Wiedervorlage', 'UserCustomField').delete
  end
end