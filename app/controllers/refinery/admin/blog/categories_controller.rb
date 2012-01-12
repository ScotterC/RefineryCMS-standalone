
    class Refinery::Admin::Blog::CategoriesController < Refinery::Admin::BaseController

      crudify :blog_category,
              :title_attribute => :title,
              :order => 'title ASC'

    end

