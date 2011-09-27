require 'spec_helper'

module Betfair
  
  describe General do 
    
    describe "login success"  do
      it "should return a session token" do
        savon.expects(:login).returns(:success)
        session_token = Betfair::General.new.login('username', 'password', 82, 0, 0, nil) 
        session_token.should_not be_nil        
      end
    end
    
    describe "login fail"  do
      it "should return an error" do
        savon.expects(:login).returns(:fail)
        error_code = Betfair::General.new.login('username', 'password', 82, 0, 0, nil) 
        error_code.should_not be_nil        
      end
    end
        
    describe "proxy success"  do
      it "should return a session token" do
        savon.expects(:login).returns(:success)
        proxy = 'http://localhost:8888'
        session_token = Betfair::General.new(proxy).login('username', 'password', 82, 0, 0, nil) 
        session_token.should_not be_nil        
      end
    end
    
    describe "proxy fail"  do
      it "should return an error" do
        savon.expects(:login).returns(:fail)
        proxy = 'http://localhost:8888'
        error_code = Betfair::General.new(proxy).login('username', 'password', 82, 0, 0, nil) 
        error_code.should_not be_nil        
      end
    end
    
    describe "savon logging on"  do
      it "should return a session token" do
        savon.expects(:login).returns(:success)
        proxy = nil
        logging = true
        session_token = Betfair::General.new(proxy, logging).login('username', 'password', 82, 0, 0, nil) 
        session_token.should_not be_nil        
      end
    end
    
    describe "keep alive success"  do
      it "should return a session token" do
        savon.expects(:keep_alive).returns(:success)
        session_token = Betfair::General.new.keep_alive(session_token) 
        session_token.should_not be_nil        
      end
    end
    
    # Work out how to to later if really need to
    # describe "keep alive fail"  do
    #   it "should return an error" do
    #     savon.expects(:keep_alive).returns(:fail)
    #     error_code = Betfair::General.new.keep_alive('asdsad') 
    #     error_code.should_not be_nil        
    #   end
    # end
    
    describe "logout success"  do
      it "should return a session token" do
        savon.expects(:logout).returns(:success)
        session_token = Betfair::General.new.logout(session_token) 
        session_token.should be_nil        
      end
    end
    
    # Work out how to to later if really need to
    # describe "logout fail"  do
    #   it "should return an error" do
    #     savon.expects(:logout).returns(:fail)
    #     error_code = Betfair::General.new.logout(session_token) 
    #     error_code.should_not be_nil        
    #   end
    # end
        
  end
  
end