module Betfair

  class General
              
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
      
      check_response(response.to_hash[:login_response][:result][:header])       
    end
    
    def keep_alive(session_token)
      response = @global_service.request :bf, :keepAlive do 
        soap.body = { 'bf:request' => { :header => api_request_header(session_token) } }
      end      
      check_response(response.to_hash[:keep_alive_response][:result][:header])       
    end
  
    def logout(session_token)
      response = @global_service.request :bf, :logout do 
        soap.body = { 'bf:request' => { :header => api_request_header(session_token) } }
      end      
      check_response(response.to_hash[:logout_response][:result][:header]) 
    end
        
    def exchange(exchange_id)   
      exchange_id == 2  ? @aus_service : @uk_service
    end

    def api_request_header(session_token)      
      { :client_stamp => 0, :session_token => session_token }
    end

    def check_response(response_header)      
      response_header[:error_code] == 'OK' ? response_header[:session_token] : response_header[:error_code]
  	end

  	def initialize(proxy = nil, logging = nil)
      
      logging == true ? Savon.log = true : Savon.log = false
  		
  		@global_service = Savon::Client.new do |wsdl, http|
  		  wsdl.endpoint = 'https://api.betfair.com/global/v3/BFGlobalService'
  		  wsdl.namespace = 'https://www.betfair.com/global/v3/BFGlobalService'		     
  		  http.proxy = proxy if !proxy.nil?
  		end

  		@uk_service = Savon::Client.new do |wsdl, http|
  		  wsdl.endpoint = 'https://api.betfair.com/exchange/v5/BFExchangeService'
        wsdl.namespace = 'http://www.betfair.com/exchange/v3/BFExchangeService/UK'
        http.proxy = proxy if !proxy.nil?
  		end

  		@aus_service = Savon::Client.new do |wsdl, http|
  		  wsdl.endpoint = 'https://api-au.betfair.com/exchange/v5/BFExchangeService'
  		  wsdl.namespace = 'http://www.betfair.com/exchange/v3/BFExchangeService/AUS'
  		  http.proxy = proxy if !proxy.nil?
  		end

  	end
      
  end
  
end