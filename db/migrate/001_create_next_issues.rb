class CreateNextIssues < ActiveRecord::Migration[4.2]
  def self.up
    create_table :next_issues do |t|
      t.column :issue_id, :integer
      t.column :user_id, :integer
      t.column :position, :integer
    end
  end
  
  def self.down
    drop_table :next_issues
  end
end
