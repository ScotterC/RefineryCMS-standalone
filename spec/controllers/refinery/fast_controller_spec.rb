require 'spec_helper'
module Refinery
  describe FastController do
    it "should render the wymiframe template" do
    	@refinery_user = Factory(:refinery_user)
      get :wymiframe

      response.should be_success
      response.should render_template(:wymiframe)
    end
  end
end
