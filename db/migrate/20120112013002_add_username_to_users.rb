class AddUsernameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :persistence_token, :string
    add_column :users, :username, :string
  end

  def self.down
    remove_column :users, :persistence_token
    remove_column :users, :username
  end
end
