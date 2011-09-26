require 'spec_helper'

module Betfair
  
  describe General do 
    
    describe "login success"  do
      it "should return a session token" do
        savon.expects(:login).returns(:success) # Using Savon Spec gem
        session_token = Betfair::General.new.login('username', 'password', 82, 0, 0, nil) # When 
        session_token.should_not be_nil # Then        
      end
    end
    
    describe "login fail"  do
      it "should return an error" do
        savon.expects(:login).returns(:fail) # Using Savon Spec gem
        error_code = Betfair::General.new.login('username', 'password', 82, 0, 0, nil) # When 
        error_code.should_not be_nil # Then        
      end
    end
    
    describe "keep alive success"  do
      it "should return a session token" do
        savon.expects(:keep_alive).returns(:success) # Using Savon Spec gem
        session_token = Betfair::General.new.keep_alive(session_token) # When 
        session_token.should_not be_nil # Then        
      end
    end
    
    # Work out how to to later if really need to
    # describe "keep alive fail"  do
    #   it "should return an error" do
    #     savon.expects(:keep_alive).returns(:fail) # Using Savon Spec gem
    #     error_code = Betfair::General.new.keep_alive() # When 
    #     error_code.should_not be_nil # Then        
    #   end
    # end
    
    describe "logout success"  do
      it "should return a session token" do
        savon.expects(:logout).returns(:success) # Using Savon Spec gem
        session_token = Betfair::General.new.logout(session_token) # When 
        session_token.should be_nil # Then        
      end
    end
    
    # Work out how to to later if really need to
    # describe "logout fail"  do
    #   it "should return an error" do
    #     savon.expects(:logout).returns(:fail) # Using Savon Spec gem
    #     error_code = Betfair::General.new.logout(session_token) # When 
    #     error_code.should_not be_nil # Then        
    #   end
    # end
        
  end
  
end