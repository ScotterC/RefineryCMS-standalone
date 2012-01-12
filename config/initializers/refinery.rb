
#::ActionDispatch::Static, ::ActionDispatch::Static, "#{Rails.root}/public"

require "#{Rails.root}/lib/refinery.rb"
require "authenticated_system"
require "refinery/activity"
require "refinery/base_presenter"
require "refinery/configuration"
require "refinery/crud"
require "refinery/engine"
require "refinery/menu"
require "refinery/menu_item"
require "refinery/plugin"
require "refinery/plugins"
require "pages/marketable_routes"
require "pages/tabs"

Rails.root.join('app', 'presenters')
Rails.root.join('vendor', '**', '**', 'app', 'presenters')
#Refinery.roots.map{|r| r.join('**', 'app', 'presenters')}



ActsAsIndexed.configure do |config|
  config.index_file = Rails.root.join('tmp', 'index')
  config.index_file_depth = 3
  config.min_word_size = 3
end



::Rack::Utils.module_eval do
  def escape(s)
    regexp = case
      when RUBY_VERSION >= '1.9' && s.encoding === Encoding.find('UTF-8')
        /([^ a-zA-Z0-9_.-]+)/u
      else
        /([^ a-zA-Z0-9_.-]+)/n
      end
    s.to_s.gsub(regexp) {
      '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
    }.tr(' ', '+')
  end
end if ::Rack.version <= '1.2.1'



WillPaginate::ViewHelpers.pagination_options[:previous_label] = "&laquo;".html_safe
WillPaginate::ViewHelpers.pagination_options[:next_label] = "&raquo;".html_safe


app_images = Dragonfly[:refinery_images]
app_images.configure_with(:imagemagick)
app_images.configure_with(:rails) do |c|
  c.datastore.root_path = Rails.root.join('public', 'system', 'images').to_s
  # This url_format it so that dragonfly urls work in traditional
  # situations where the filename and extension are required, e.g. lightbox.
  # What this does is takes the url that is about to be produced e.g.
  # /system/images/BAhbB1sHOgZmIiMyMDEwLzA5LzAxL1NTQ19DbGllbnRfQ29uZi5qcGdbCDoGcDoKdGh1bWIiDjk0MngzNjAjYw
  # and adds the filename onto the end (say the image was 'refinery_is_awesome.jpg')
  # /system/images/BAhbB1sHOgZmIiMyMDEwLzA5LzAxL1NTQ19DbGllbnRfQ29uZi5qcGdbCDoGcDoKdGh1bWIiDjk0MngzNjAjYw/refinery_is_awesome.jpg
  c.url_format = '/system/images/:job/:basename.:format'
  c.secret = RefinerySetting.find_or_set(:dragonfly_secret,
                                      Array.new(24) { rand(256) }.pack('C*').unpack('H*').first)
end

if Refinery.s3_backend
  app_images.configure_with(:heroku, ENV['S3_BUCKET'])
  # Dragonfly doesn't set the S3 region, so we have to do this manually
  app_images.datastore.configure do |d|
    d.region = ENV['S3_REGION'] if ENV['S3_REGION'] # otherwise defaults to 'us-east-1'
  end
end

app_images.define_macro(ActiveRecord::Base, :image_accessor)
app_images.analyser.register(Dragonfly::ImageMagick::Analyser)
app_images.analyser.register(Dragonfly::Analysis::FileCommandAnalyser)

# 
# ::ApplicationController.send :include, ::Page::InstanceMethods
# ::Admin::BaseController.send :include, ::Page::Admin::InstanceMethods



File.expand_path('../pages/marketable_routes.rb', __FILE__)

app_resources = Dragonfly[:resources]
app_resources.configure_with(:rails) do |c|
  c.datastore.root_path = Rails.root.join('public', 'system', 'resources').to_s
  # This url_format makes it so that dragonfly urls work in traditional
  # situations where the filename and extension are required, e.g. lightbox.
  # What this does is takes the url that is about to be produced e.g.
  # /system/images/BAhbB1sHOgZmIiMyMDEwLzA5LzAxL1NTQ19DbGllbnRfQ29uZi5qcGdbCDoGcDoKdGh1bWIiDjk0MngzNjAjYw
  # and adds the filename onto the end (say the file was 'refinery_is_awesome.pdf')
  # /system/images/BAhbB1sHOgZmIiMyMDEwLzA5LzAxL1NTQ19DbGllbnRfQ29uZi5qcGdbCDoGcDoKdGh1bWIiDjk0MngzNjAjYw/refinery_is_awesome.pdf
  c.url_format = '/system/resources/:job/:basename.:format'
  c.secret = RefinerySetting.find_or_set(:dragonfly_secret,
                                         Array.new(24) { rand(256) }.pack('C*').unpack('H*').first)
end

if Refinery.s3_backend
  app_resources.configure_with(:heroku, ENV['S3_BUCKET'])
  # Dragonfly doesn't set the S3 region, so we have to do this manually
  app_resources.datastore.configure do |d|
    d.region = ENV['S3_REGION'] if ENV['S3_REGION'] # defaults to 'us-east-1'
  end
end

app_resources.define_macro(ActiveRecord::Base, :resource_accessor)
app_resources.analyser.register(Dragonfly::Analysis::FileCommandAnalyser)
app_resources.content_disposition = :attachment


RefineryTest::Application.configure do
  ### Extend active record ###

  config.to_prepare do
    require File.expand_path('../../../lib/pages/tabs', __FILE__)
  end

  # config.middleware.insert_after 'Rack::Lock', 'Dragonfly::Middleware', :resources
  
  # config.middleware.insert_before 'Dragonfly::Middleware', 'Rack::Cache', {
  #   :verbose     => Rails.env.development?,
  #   :metastore   => "file:#{Rails.root.join('tmp', 'dragonfly', 'cache', 'meta')}",
  #   :entitystore => "file:#{Rails.root.join('tmp', 'dragonfly', 'cache', 'body')}"
  # }

  config.after_initialize do
    Refinery::Plugin.register do |plugin|
      plugin.pathname = Rails.root
      plugin.name = 'refinery_dashboard'
      plugin.url = {:controller => '/admin/dashboard', :action => 'index'}
      plugin.menu_match = /(admin|refinery)\/(refinery_)?dashboard$/
      plugin.directory = 'dashboard'
      plugin.version = %q{1.0.0}
      plugin.always_allow_access = true
      plugin.dashboard = true
    end

    Refinery::Plugin.register do |plugin|
      plugin.pathname = Rails.root
      plugin.name = 'refinery_files'
      plugin.url = {:controller => '/admin/resources', :action => 'index'}
      plugin.menu_match = /(refinery|admin)\/(refinery_)?(files|resources)$/
      plugin.version = %q{1.0.0}
      plugin.activity = {
        :class => Resource
      }
    end 

    Refinery::Plugin.register do |plugin|
      plugin.pathname = Rails.root
      plugin.name = 'refinery_pages'
      plugin.directory = 'pages'
      plugin.version = %q{1.0.0}
      plugin.menu_match = /(refinery|admin)\/page(_part)?s(_dialogs)?$/
      plugin.activity = {
        :class => Page,
        :url_prefix => 'edit',
        :title => 'title',
        :created_image => 'page_add.png',
        :updated_image => 'page_edit.png'
      }
    end    
    
    Refinery::Plugin.register do |plugin|
      plugin.pathname = Rails.root
      plugin.name = 'refinery_settings'
      plugin.url = {:controller => '/admin/refinery_settings'}
      plugin.version = %q{1.0.0}
      plugin.menu_match = /(refinery|admin)\/(refinery_)?settings$/
    end 

    Refinery::Plugin.register do |plugin|
      plugin.pathname = Rails.root
      plugin.name = 'refinery_core'
      plugin.class_name = 'RefineryEngine'
      plugin.version = %q{1.0.0}
      plugin.hide_from_menu = true
      plugin.always_allow_access = true
      plugin.menu_match = /(refinery|admin)\/(refinery_core)$/
    end

    # Register the dialogs plugin
    Refinery::Plugin.register do |plugin|
      plugin.pathname = Rails.root
      plugin.name = 'refinery_dialogs'
      plugin.version = %q{1.0.0}
      plugin.hide_from_menu = true
      plugin.always_allow_access = true
      plugin.menu_match = /(refinery|admin)\/(refinery_|pages_)?dialogs/
    end          
  end
  


  # config.middleware.insert_after 'Rack::Lock', 'Dragonfly::Middleware', :images

  # config.middleware.insert_before 'Dragonfly::Middleware', 'Rack::Cache', {
  #   :verbose     => Rails.env.development?,
  #   :metastore   => "file:#{Rails.root.join('tmp', 'dragonfly', 'cache', 'meta')}",
  #   :entitystore => "file:#{Rails.root.join('tmp', 'dragonfly', 'cache', 'body')}"
  # }

  # Refinery::Plugins.registered.each do |plugin|
  #   Refinery::Plugins.activate(plugin.name)
  # end
end

