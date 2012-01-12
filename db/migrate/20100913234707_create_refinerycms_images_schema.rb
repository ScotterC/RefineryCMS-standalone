class CreateRefinerycmsImagesSchema < ActiveRecord::Migration
  def self.up
    create_table :refinery_images, :force => true do |t|
      t.string   "image_mime_type"
      t.string   "image_name"
      t.integer  "image_size"
      t.integer  "image_width"
      t.integer  "image_height"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "image_uid"
      t.string   "image_ext"
    end unless RefineryImage.table_exists?
  end

  def self.down
    [RefineryImage].reject{|m|
      !(defined?(m) and m.respond_to?(:table_name))
    }.each do |model|
      drop_table model.table_name if model.table_exists?
    end
  end
end
