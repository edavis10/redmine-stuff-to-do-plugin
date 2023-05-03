class RemoveIdFromTimeGridIssuesUsers < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :time_grid_issues_users, :id
  end
  
  def self.down
    raise ActiveRecord::IrreversibleMigration "Can't add the deleted primary key to the table"
  end
end
