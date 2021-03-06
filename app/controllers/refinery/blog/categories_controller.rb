
  class Refinery::Blog::CategoriesController < Refinery::BlogController

    def show
      @category = BlogCategory.find(params[:id])
      # @blog_posts = @category.posts.live.includes(:comments, :categories).paginate({
      #   :page => params[:page],
      #   :per_page => RefinerySetting.find_or_set(:blog_posts_per_page, 10)
      # })
      @blog_posts = @category.posts.live.includes(:comments,:categories).page(params[:page]).per(RefinerySetting.find_or_set(:blog_posts_per_page, 10))
    end

  end
