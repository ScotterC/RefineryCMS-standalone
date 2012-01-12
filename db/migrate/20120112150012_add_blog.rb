class AddBlog < ActiveRecord::Migration
  def self.up
    create_table :blog_posts, :id => true do |t|
      t.string :title
      t.text :body
      t.boolean :draft
      t.datetime :published_at
      t.integer :user_id
      t.string :cached_slug
      t.string :custom_url
      t.text :custom_teaser
      t.timestamps
    end

    add_index :blog_posts, :id

    create_table :blog_comments, :id => true do |t|
      t.integer :blog_post_id
      t.boolean :spam
      t.string :name
      t.string :email
      t.text :body
      t.string :state
      t.timestamps
    end

    add_index :blog_comments, :id

    create_table :blog_categories, :id => true do |t|
      t.string :title
      t.string :cached_slug      
      t.timestamps
    end

    add_index :blog_categories, :id

    create_table :blog_categories_blog_posts, :id => false do |t|
    	t.primary_key :id
      t.integer :blog_category_id
      t.integer :blog_post_id
    end

    add_index :blog_categories_blog_posts, [:blog_category_id, :blog_post_id], :name => 'index_blog_categories_blog_posts_on_bc_and_bp'

    load(Rails.root.join('db', 'seeds', 'refinerycms_blog.rb').to_s)  	

    create_table :tags do |t|
      t.string :name
    end

    create_table :taggings do |t|
      t.references :tag

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.references :taggable, :polymorphic => true
      t.references :tagger, :polymorphic => true

      t.string :context

      t.datetime :created_at
    end

    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end

  def self.down
    UserPlugin.destroy_all({:name => "refinerycms_blog"})

    Page.delete_all({:link_url => "/blog"})

    drop_table :blog_posts
    drop_table :blog_comments
    drop_table :blog_categories
    drop_table :blog_categories_blog_posts  	
    drop_table :taggings
    drop_table :tags    
  end
end
