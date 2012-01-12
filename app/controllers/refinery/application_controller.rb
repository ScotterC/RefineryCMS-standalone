# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class Refinery::ApplicationController < ApplicationController
  include AuthenticatedSystem
  
  protect_from_forgery
  include Refinery::Crud
  before_filter :find_pages_for_menu, :show_welcome_page?
  after_filter :store_current_location!, :if => Proc.new {|c| c.send(:refinery_user?) rescue false}
  
  
  def admin?
    #controller_name =~ %r{^admin/}
    self.class.to_s =~ %r{^Refinery::Admin}
  end

  def from_dialog?
    params[:dialog] == 'true' or params[:modal] == 'true'
  end

  def home_page?
    root_path =~ /^#{request.path}\/?/
  end

  def just_installed?
    Role[:refinery].users.empty?
  end

  def login?
    (controller_name =~ /^(user|session)(|s)/ and not admin?) or just_installed?
  end

  protected

    # get all the pages to be displayed in the site menu.
    # def find_pages_for_menu
    #   raise NotImplementedError, 'Please implement protected method find_pages_for_menu'
    # end
    def find_pages_for_menu
      # First, apply a filter to determine which pages to show.
      # We need to join to the page's slug to avoid multiple queries.
      pages = Page.live.in_menu.includes(:slug).order('lft ASC')

      # Now we only want to select particular columns to avoid any further queries.
      # Title is retrieved in the next block below so it's not here.
      %w(id depth parent_id lft rgt link_url menu_match).each do |column|
        pages = pages.select(Page.arel_table[column.to_sym])
      end

      # If we have translations then we get the title from that table.
      if Page.respond_to?(:translation_class)
        pages = pages.joins(:translations).select("#{::Page.translation_class.table_name}.title as page_title")
      else
        pages = pages.select('title as page_title')
      end

      # Compile the menu
      @menu_pages = Refinery::Menu.new(pages)
    end

    # use a different model for the meta information.
    def present(model)
      presenter = (Object.const_get("#{model.class}Presenter") rescue ::Refinery::BasePresenter)
      @meta = presenter.new(model)
    end

    def show_welcome_page?
      if just_installed? and controller_name != 'users'
        render :template => '/welcome', :layout => 'login'
      end
    end

  private
    def store_current_location!
      if admin? and request.get? and !request.xhr? and !from_dialog?
        # ensure that we don't redirect to AJAX or POST/PUT/DELETE urls
        session[:refinery_return_to] = request.path
      end
    end
end
