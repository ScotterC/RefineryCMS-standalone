class PagesController < ApplicationController

  # This action is usually accessed with the root path, normally '/'
  def home
    error_404 unless (@page = Page.where(:link_url => '/').first).present?
  end

  # This action can be accessed normally, or as nested pages.
  # Assuming a page named "mission" that is a child of "about",
  # you can access the pages with the following URLs:
  #
  #   GET /pages/about
  #   GET /about
  #
  #   GET /pages/mission
  #   GET /about/mission
  #
  def show
    @page = Page.find("#{params[:path]}/#{params[:id]}".split('/').last)

    if @page.try(:live?) || (refinery_user? && current_user.authorized_plugins.include?("refinery_pages"))
      # if the admin wants this to be a "placeholder" page which goes to its first child, go to that instead.
      if @page.skip_to_first_child && (first_live_child = @page.children.order('lft ASC').live.first).present?
        redirect_to first_live_child.url and return
      elsif @page.link_url.present?
        redirect_to @page.link_url and return
      end
    else
      error_404
    end
  end
  
  def error_404(exception=nil)
    if (@page = ::Page.where(:menu_match => '^/404$').includes(:parts, :slugs).first).present?
      # render the application's custom 404 page with layout and meta.
      render :template => '/pages/show',
             :format => 'html',
             :status => 404
    else
      super
    end
  end

  protected
    def find_pages_for_menu
      # First, apply a filter to determine which pages to show.
      # We need to join to the page's slug to avoid multiple queries.
      pages = ::Page.live.in_menu.includes(:slug).order('lft ASC')

      # Now we only want to select particular columns to avoid any further queries.
      # Title is retrieved in the next block below so it's not here.
      %w(id depth parent_id lft rgt link_url menu_match).each do |column|
        pages = pages.select(::Page.arel_table[column.to_sym])
      end

      # If we have translations then we get the title from that table.
      if ::Page.respond_to?(:translation_class)
        pages = pages.joins(:translations).select("#{::Page.translation_class.table_name}.title as page_title")
      else
        pages = pages.select('title as page_title')
      end

      # Compile the menu
      @menu_pages = ::Refinery::Menu.new(pages)
    end

    def render(*args)
      present(@page) unless admin? or @meta.present?
      super
    end

  private
    def store_current_location!
      return super if admin?

      session[:website_return_to] = url_for(@page.url) if @page.try(:present?)
    end


end




