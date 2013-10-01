class AddOfficerToIssue < ActiveRecord::Migration
    def up
      add_column :issues, :officer_id, :integer
    end

    def down
      remove_column :issues, :parent_id
    end
end