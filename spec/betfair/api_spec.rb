require 'spec_helper'

module Betfair

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

  describe "Placing and cancelling bets" do
    
    before(:all) do 
      @bf = Betfair::API.new
      savon.expects(:login).returns(:success)      
      @session_token = @bf.login('username', 'password', 82, 0, 0, nil) 
    end
    
    describe "place bet success"  do
      it "should place a bet on the exchange via the api" do
        savon.expects(:place_bets).returns(:success)
        bet = @bf.place_bet(1, 104184109, 58805, 'B', 10.0, 5.0)       
        bet.should_not be_nil
      end
    end
    
    describe "place bet fail"  do
      it "should return an error message" do
        savon.expects(:place_bets).returns(:fail)
        error_code = @bf.place_bet(1, 104184109, 58805, 'B', 2.0, 2.0)       
        error_code[:result_code].should eq('INVALID_SIZE')
      end
    end
    
    describe "cancel bet success"  do
      it "should cancel a bet on the exchange via the api" do
        savon.expects(:cancel_bets).returns(:success)
        bet = @bf.cancel_bet(3, 16939689578)       
        bet.should_not be_nil
      end
    end
    
    describe "cancel bet fail"  do
      it "should fail to cancel a bet on the exchange via the api" do
        savon.expects(:cancel_bets).returns(:fail)
        error_code = @bf.cancel_bet(3, 16939689578)        
        error_code.should eq('API_ERROR')
      end
    end
    
  end
  
  
  describe "Basic read methods from the API" do 

    before(:all) do 
      @bf = Betfair::API.new
      savon.expects(:login).returns(:success)
      @session_token = @bf.login('username', 'password', 82, 0, 0, nil) 
    end    

    describe "get all markets success"  do
      it "should return a hash of all markets given the exchange id and and array of market type ids" do
        savon.expects(:get_all_markets).returns(:success)
        markets = @bf.get_all_markets(1, [1,3], nil, nil, nil, nil)        
        markets.should_not be_nil        
      end
    end

    describe "get all markets fail"  do
      it "should return an error message given the exchange id and and array of market type ids and no session id" do
        savon.expects(:get_all_markets).returns(:fail)
        error_code = @bf.get_all_markets(1, [1,3], nil, nil, nil, nil)        
        error_code.should eq('API_ERROR')        
      end
    end

    describe "get market success"  do
      it "should return the details for a market given the exchange id and market id" do
        savon.expects(:get_market).returns(:success)
        market = @bf.get_market(2, 10038633)        
        market.should_not be_nil        
      end
    end

    describe "get markets fail"  do
      it "should return an error message given the wrong exchange id or market id" do
        savon.expects(:get_market).returns(:fail)
        error_code = @bf.get_market(2, 10038633)        
        error_code.should eq('INVALID_MARKET')        
      end
    end

    describe "get market prices compressed success"  do
      it "should return comrpessed market prices given the exchange id and market id" do
        savon.expects(:get_market_prices_compressed).returns(:success)
        market = @bf.get_market_prices_compressed(2, 10038633)        
        market.should_not be_nil      
      end
    end

    describe "get market prices compressed fail"  do
      it "should return an error message given the wrong exchange id or market id" do
        savon.expects(:get_market_prices_compressed).returns(:fail)
        error_code = @bf.get_market_prices_compressed(2, 10038633)        
        error_code.should eq('INVALID_MARKET')        
      end
    end

  end
     
  describe "General logins, logouts methods and proxys and Savon logging etc" do 

    before(:all) do
    end

    describe "login success"  do
      it "should return a session token" do
        savon.expects(:login).returns(:success)
        bf = Betfair::API.new({:username => 'username', :password => 'password'})
        bf.session_token.should be_an_instance_of(String)
      end
    end

    describe "no login credentials"  do
      it "should not return a session token" do
        bf = Betfair::API.new({})
        bf.session_token.should be_nil
      end
    end
    
    describe "login fail"  do
      it "should return an error" do
        savon.expects(:login).returns(:fail)
        bf = Betfair::API.new({:username => 'username', :password => 'password'})
        bf.error_code.should eq('PRODUCT_REQUIRES_FUNDED_ACCOUNT')
      end
    end

    describe "proxy success"  do
      it "should return a session token" do
        savon.expects(:login).returns(:success)
        proxy = 'http://localhost:8888'
        bf = Betfair::API.new({:proxy => proxy, :username => 'username', :password => 'password'})
        bf.session_token.should be_an_instance_of(String)
      end
    end

    describe "proxy fail"  do
      it "should return an error" do
        savon.expects(:login).returns(:fail)
        proxy = 'http://localhost:8888'
        bf = Betfair::API.new({:proxy => proxy, :username => 'username', :password => 'password'})
        bf.error_code.should eq('PRODUCT_REQUIRES_FUNDED_ACCOUNT')         
      end
    end

    describe "savon logging on"  do
      it "should return a session token" do
        savon.expects(:login).returns(:success)
        bf = Betfair::API.new({:proxy => nil, :logging => true, :username => 'username', :password => 'password'})
        bf.session_token.should be_an_instance_of(String)    
      end
    end

  end
  
end