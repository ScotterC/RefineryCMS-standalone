class CreateRefinerycmsPagesSchema < ActiveRecord::Migration
  def self.up
    unless PagePart.table_exists?
      create_table :page_parts, :force => true do |t|
        t.integer  "page_id"
        t.string   "title"
        t.text     "body"
        t.integer  "position"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      add_index :page_parts, ["id"], :name => "index_page_parts_on_id"
      add_index :page_parts, ["page_id"], :name => "index_page_parts_on_page_id"
    end

    unless Page.table_exists?
      create_table :pages, :force => true do |t|
        t.string   "title"
        t.integer  "parent_id"
        t.integer  "position"
        t.string   "path"
        t.datetime "created_at"
        t.datetime "updated_at"
        t.string   "meta_keywords"
        t.text     "meta_description"
        t.boolean  "show_in_menu",        :default => true
        t.string   "link_url"
        t.string   "menu_match"
        t.boolean  "deletable",           :default => true
        t.string   "custom_title"
        t.string   "custom_title_type",   :default => "none"
        t.boolean  "draft",               :default => false
        t.string   "browser_title"
        t.boolean  "skip_to_first_child", :default => false
        t.integer  "lft"
        t.integer  "rgt"
        t.integer  "depth"
      end

      add_index :pages, ["depth"], :name => "index_pages_on_depth"
      add_index :pages, ["id"], :name => "index_pages_on_id"
      add_index :pages, ["lft"], :name => "index_pages_on_lft"
      add_index :pages, ["parent_id"], :name => "index_pages_on_parent_id"
      add_index :pages, ["rgt"], :name => "index_pages_on_rgt"
    end
  end

  def self.down
    [Page, PagePart].reject{|m|
      !(defined?(m) and m.respond_to?(:table_name))
    }.each do |model|
      drop_table model.table_name if model.table_exists?
    end
  end
end
