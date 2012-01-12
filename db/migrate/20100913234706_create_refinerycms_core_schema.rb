class CreateRefinerycmsCoreSchema < ActiveRecord::Migration
  def self.up
      create_table :slugs, :force => true do |t|
        t.string   "name"
        t.integer  "sluggable_id"
        t.integer  "sequence",                     :default => 1, :null => false
        t.string   "sluggable_type", :limit => 40
        t.string   "scope",          :limit => 40
        t.string   "locale",         :limit => 5
        t.datetime "created_at"
      end


      add_index :slugs, :locale


      add_index :slugs, ["name", "sluggable_type", "scope", "sequence"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
      add_index :slugs, ["sluggable_id"], :name => "index_slugs_on_sluggable_id"
  end

  def self.down
    [Slug].reject{|m|
      !(defined?(m) and m.respond_to?(:table_name))
    }.each do |model|
      drop_table model.table_name if model.table_exists?
    end
  end
end
