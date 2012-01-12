class AddUserPlugins < ActiveRecord::Migration
  def self.up
    create_table :user_plugins, :force => true do |t|
      t.integer "user_id"
      t.string  "name"
      t.integer "position"
    end

    add_index :user_plugins, ["name"], :name => "index_user_plugins_on_title"
    add_index :user_plugins, ["user_id", "name"], :name => "index_unique_user_plugins", :unique => true
  end

  def self.down
    drop_table :user_plugins
  end
end
