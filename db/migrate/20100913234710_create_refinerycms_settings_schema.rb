class CreateRefinerycmsSettingsSchema < ActiveRecord::Migration
  def self.up
    unless RefinerySetting.table_exists?
      create_table :refinery_settings, :force => true do |t|
        t.string   "name"
        t.text     "value"
        t.boolean  "destroyable",             :default => true
        t.datetime "created_at"
        t.datetime "updated_at"
        t.string   "scoping"
        t.boolean  "restricted",              :default => false
        t.string   "callback_proc_as_string"
      end

      add_index :refinery_settings, ["name"], :name => "index_refinery_settings_on_name"
    end
  end

  def self.down
    [RefinerySetting].reject{|m|
      !(defined?(m) and m.respond_to?(:table_name))
    }.each do |model|
      drop_table model.table_name if model.table_exists?
    end
  end
end
