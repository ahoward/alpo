class CreateDropboxes < ActiveRecord::Migration
  def self.up
    create_table :dropboxes do |t|
      t.string :name
      t.references :real_user
      t.references :effective_user

      t.timestamps
    end
  end

  def self.down
    drop_table :dropboxes
  end
end
