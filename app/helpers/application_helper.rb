module ApplicationHelper
  
  def admin?
    controller_name =~ %r{^admin/}
  end

  def error_404(exception=nil)
    # fallback to the default 404.html page.
    file = Rails.root.join('public', '404.html')
    file = Refinery.roots('core').join('public', '404.html') unless file.exist?
    render :file => file.cleanpath.to_s,
           :layout => false,
           :status => 404
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

  def local_request?
    Rails.env.development? or request.remote_ip =~ /(::1)|(127.0.0.1)|((192.168).*)/
  end

  def login?
    (controller_name =~ /^(user|session)(|s)/ and not admin?) or just_installed?
  end
  
end
