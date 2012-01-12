class AddRolesTable < ActiveRecord::Migration
  def self.up
    # Postgres apparently requires the roles_users table to exist before creating the roles table.
    create_table :roles_users, :id => false, :force => true do |t|
      t.integer "user_id"
      t.integer "role_id"
    end unless RolesUsers.table_exists?

    create_table :roles, :force => true do |t|
      t.string "name"
    end unless Role.table_exists?
    
    add_index :roles_users, [:role_id, :user_id]
    add_index :roles_users, [:user_id, :role_id]
  end

  def self.down
    
    remove_index :roles_users, :column => [:role_id, :user_id]
    remove_index :roles_users, :column => [:user_id, :role_id]
    drop_table :roles_users
    drop_table :roles
  end
end
