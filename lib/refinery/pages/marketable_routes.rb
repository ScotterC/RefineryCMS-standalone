
if Page.use_marketable_urls?

  # Add any parts of routes as reserved words.
  route_paths = RefineryTest::Application.routes.named_routes.routes.map{|name, route| route.path}
  Page.friendly_id_config.reserved_words |= route_paths.map { |path|
    path.to_s.gsub(/^\//, '').to_s.split('(').first.to_s.split(':').first.to_s.split('/')
  }.flatten.reject{|w| w =~ /\_/}.uniq
end
