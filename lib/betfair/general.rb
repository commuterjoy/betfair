# bf = Betfair::API.new()
module Betfair

  class General
              
    # session_token = bf.login('username', 'password', 82, 0, 0, nil)
    def login(username, password, product_id, vendor_software_id, location_id, ip_address)
      response = @global_service.request :bf, :login do 
        soap.body = { 'bf:request' => { :username => username, 
                                        :password => password, 
                                        :productId => product_id, 
                                        :vendorSoftwareId => vendor_software_id, 
                                        :locationId => location_id, 
                                        :ipAddress => ip_address 
                                       } 
                    }
      end
      
      if check_response(:login_response, response) == true
        return response.to_hash[:login_response][:result][:header][:session_token] 
      else
        return response.to_hash[:login_response][:result][:error_code]
      end
    end
    
    # keep_alive = api.keep_alive(session_token)
    def keep_alive(session_token)
      response = @global_service.request :bf, :keepAlive do 
        soap.body = { 'bf:request' => { :header => api_request_header(session_token) } }
      end
      
      if check_response(:keep_alive_response, response) == true
        return response.to_hash[:keep_alive_response][:result][:header][:session_token] 
      else
        return response.to_hash[:keep_alive_response][:result][:error_code]
      end
      
    end
  
    # logout = api.logout(session_token)
    def logout(session_token)
      response = @global_service.request :bf, :logout do 
        soap.body = { 'bf:request' => { :header => api_request_header(session_token) } }
      end
      
      if check_response(:logout_response, response) == true
        return response.to_hash[:logout_response][:result][:header][:session_token] 
      else
        return response.to_hash[:logout_response][:result][:error_code]
      end
    end
        
    def exchange(exchange_id)   
      if exchange_id == 2   
        return @aus_service 
      else
        return @uk_service
      end
    end

    def api_request_header(session_token)      
      return { :client_stamp => 0, :session_token => session_token }
    end

    def check_response(response_symbol, response)
  		return true if response.to_hash[response_symbol][:result][:header][:error_code] == 'OK'
  	end

  	def initialize

  		@global_service = Savon::Client.new do |wsdl, http|
  		  wsdl.endpoint = 'https://api.betfair.com/global/v3/BFGlobalService'
  		  wsdl.namespace = 'https://www.betfair.com/global/v3/BFGlobalService'		     
  		end

  		@uk_service = Savon::Client.new do |wsdl, http|
  		  wsdl.endpoint = 'https://api.betfair.com/exchange/v5/BFExchangeService'
        wsdl.namespace = 'http://www.betfair.com/exchange/v3/BFExchangeService/UK'
  		end

  		@aus_service = Savon::Client.new do |wsdl, http|
  		  wsdl.endpoint = 'https://api-au.betfair.com/exchange/v5/BFExchangeService'
  		  wsdl.namespace = 'http://www.betfair.com/exchange/v3/BFExchangeService/AUS'
  		end

  	end
      
  end
  
end