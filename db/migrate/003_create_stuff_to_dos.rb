class CreateStuffToDos < ActiveRecord::Migration
  def self.up
    create_table :stuff_to_dos do |t|
      t.column :user_id, :integer
      t.column :position, :integer
      t.column :stuff_id, :integer
      t.column :stuff_type, :string
    end

    add_index :stuff_to_dos, :user_id
    add_index :stuff_to_dos, :stuff_id
    add_index :stuff_to_dos, :stuff_type
  end
  
  def self.down
    drop_table :stuff_to_dos
  end
end
