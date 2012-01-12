class Refinery::FastController < Refinery::ApplicationController

  def wymiframe
    render :template => "/wymiframe", :layout => false
  end

end
