class CreateRooms < ActiveRecord::Migration
  def self.up
    create_table :rooms do |t|
      t.integer :user_id
      t.string :name
      t.string :hash_tag
      t.text :site

      t.timestamps
    end
  end

  def self.down
    drop_table :rooms
  end
end
