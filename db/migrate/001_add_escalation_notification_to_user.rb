class AddEscalationNotificationToUser < ActiveRecord::Migration
  def self.up
    CustomField.create({:type => 'UserCustomField', :name => 'Wiedervorlage', :field_format => 'bool', :editable => true})
  end

  def self.down
    CustomField.find_by_name_and_type('Wiedervorlage', 'UserCustomField').delete
  end
end