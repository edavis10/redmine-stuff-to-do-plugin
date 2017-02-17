class AddStuffToDoReportees  < ActiveRecord::Migration
  def self.up 
    create_table :stuff_to_do_reportees do |t|
      t.column :user_id, :integer
      t.column :reportee_id, :integer
    end
  end
  
  def self.down
    drop_table :stuff_to_do_reportees
  end
end
