module Refinery
  class FastController < ApplicationController

    def wymiframe
      render :template => "/wymiframe", :layout => false
    end

  end
end
