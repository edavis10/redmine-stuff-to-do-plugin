class CreateTimeGridIssuesUsers < ActiveRecord::Migration
  def self.up
    create_table :time_grid_issues_users do |t|
      t.column :issue_id, :integer
      t.column :user_id, :integer
    end

    add_index :time_grid_issues_users, :issue_id
    add_index :time_grid_issues_users, :user_id
  end
  
  def self.down
    drop_table :time_grid_issues_users
  end
end
