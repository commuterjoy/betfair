require 'spec_helper'

module Betfair
  
  describe "General logins, logouts and proxys etc" do 
    
    before(:each) do 
      @bf = Betfair::API.new
    end
    
    describe "login success"  do
      it "should return a session token" do
        savon.expects(:login).returns(:success)
        session_token = @bf.login('username', 'password', 82, 0, 0, nil) 
        session_token.should_not be_nil        
      end
    end
    
    describe "login fail"  do
      it "should return an error" do
        savon.expects(:login).returns(:fail)
        error_code = @bf.login('username', 'password', 82, 0, 0, nil) 
        error_code.should_not be_nil        
      end
    end
        
    describe "proxy success"  do
      it "should return a session token" do
        savon.expects(:login).returns(:success)        
        proxy = 'http://localhost:8888'
        session_token = Betfair::API.new(proxy).login('username', 'password', 82, 0, 0, nil) 
        session_token.should_not be_nil        
      end
    end
    
    describe "proxy fail"  do
      it "should return an error" do
        savon.expects(:login).returns(:fail)
        proxy = 'http://localhost:8888'
        error_code = Betfair::API.new(proxy).login('username', 'password', 82, 0, 0, nil) 
        error_code.should_not be_nil        
      end
    end
    
    describe "savon logging on"  do
      it "should return a session token" do
        savon.expects(:login).returns(:success)
        proxy = nil
        logging = true
        session_token =  Betfair::API.new(proxy, logging).login('username', 'password', 82, 0, 0, nil)
        session_token.should_not be_nil        
      end
    end
    
    describe "keep alive success"  do
      it "should return a session token" do
        savon.expects(:keep_alive).returns(:success)
        session_token = @bf.keep_alive(session_token) 
        session_token.should_not be_nil        
      end
    end
    
    # Work out how to to later if really need to
    # describe "keep alive fail"  do
    #   it "should return an error" do
    #     savon.expects(:keep_alive).returns(:fail)
    #     error_code = @bf.keep_alive('asdsad') 
    #     error_code.should_not be_nil        
    #   end
    # end
    
    describe "logout success"  do
      it "should return a session token" do
        savon.expects(:logout).returns(:success)
        session_token = @bf.logout(session_token) 
        session_token.should be_nil        
      end
    end
    # 
    # Work out how to to later if really need to
    # describe "logout fail"  do
    #   it "should return an error" do
    #     savon.expects(:logout).returns(:fail)
    #     error_code = @bf.logout(session_token) 
    #     error_code.should_not be_nil        
    #   end
    # end
        
  end
  
  describe "Read methods from the API" do 
    
    before(:each) do 
      @session_token = Betfair::API.new.login('username', 'password', 82, 0, 0, nil) 
    end
    
    # describe "get all markets"  do
    #   it "should return a hash of all markets" do
    #     savon.expects(:get_all_markets).returns(:success)
    #     markets = Betfair::API.new.get_all_markets(@session_token, 1)        
    #     markets.should_not be_nil        
    #   end
    # end
  
  end
  
end