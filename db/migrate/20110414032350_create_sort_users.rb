class CreateSortUsers < ActiveRecord::Migration
  def self.up
    create_table :sort_users do |t|
      t.integer :user_id
      t.integer :item_id
      t.integer :position
    end
    add_index :sort_users, :user_id
    add_index :sort_users, :item_id
  end

  def self.down
    drop_table :sort_users
  end
end
