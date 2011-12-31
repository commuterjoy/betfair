require 'spec_helper'

module Helpers

  describe "Helper methods for mashing the data from the API" do 

    before(:all) do
      @bf = Betfair::API.new
      savon.expects(:login).returns(:success)
      @session_token = @bf.login('username', 'password', 82, 0, 0, nil)
      @helpers = Betfair::Helpers.new
    end
    
    describe "Create a hash for the market details"  do
      it "pulls the relevant stuff out of market details and puts it in a hash" do
        savon.expects(:get_market).returns(:success)
        market = @bf.get_market(2, 10038633)
        market_info = @helpers.market_info(market)
        market_info.should_not be_nil        
      end
    end
    
    describe "Cleans up the get market details"  do
      it "sort the runners for each market out " do
        savon.expects(:get_market).returns(:success)
        market = @bf.get_market(2, 10038633)
        details = @helpers.details(market)
        details.should_not be_nil        
      end
    end

    describe "Get the price string for a runner"  do
      it "so that we can combine it together with market info" do
        savon.expects(:get_market_prices_compressed).returns(:success)
        prices = @bf.get_market_prices_compressed(2, 10038633)
        prices = @helpers.prices(prices)
        prices.should_not be_nil        
      end
    end
   
    describe "Combine market details and runner prices api call"  do
      it "Combines the two api calls of get_market and get_market_prices_compressed " do
        
        savon.expects(:get_market).returns(:success)
        market = @bf.get_market(2, 10038633)
        
        savon.expects(:get_market_prices_compressed).returns(:success)
        prices = @bf.get_market_prices_compressed(2, 10038633)
                       
        combined = @helpers.combine(market, prices)
        combined.should_not be_nil        
      end
    end  

  end

end