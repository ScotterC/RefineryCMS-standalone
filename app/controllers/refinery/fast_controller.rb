class Refinery::FastController < Refinery::ApplicationController

  def wymiframe
    render :template => "/refinery/wymiframe", :layout => false
  end

end
