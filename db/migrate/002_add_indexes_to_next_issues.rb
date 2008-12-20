class AddIndexesToNextIssues < ActiveRecord::Migration
  def self.up
    add_index :next_issues, :issue_id
    add_index :next_issues, :user_id
  end
  
  def self.down
    remove_index :next_issues, :issue_id
    remove_index :next_issues, :user_id
  end
end
