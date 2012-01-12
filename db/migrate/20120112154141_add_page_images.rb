class AddPageImages < ActiveRecord::Migration
  def self.up
    create_table :image_pages, :id => false do |t|
    	t.primary_key :id
      t.integer :refinery_image_id
      t.integer :page_id
      t.integer :position
      t.text :caption
      t.string :page_type, :default => "page"
    end

    ImagePage.create_translation_table!({:caption => :string}, {:migrate_data => true})

    add_index :image_pages, :refinery_image_id
    add_index :image_pages, :page_id  	
  end

  def self.down
  	ImagePage.drop_translation_table! :migrate_data => true
  	drop_table :image_pages
  end
end
