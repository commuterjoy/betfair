module Betfair
  
  class API
    
    attr_accessor :session_token, :error_code
    
    def place_bet(exchange_id, market_id, runner_id, bet_type, price, size)		
      bf_bet = { :marketId => market_id, :selectionId => runner_id, :betType => bet_type, :price => price, :size => size, :asianLineId => 0, :betCategoryType => 'E', :betPersistenceType => 'NONE', :bspLiability => 0 }      
      response = exchange(exchange_id).request :bf, :placeBets do
        soap.body = { 'bf:request' => { :header => api_request_header, :bets => { 'PlaceBets' => [bf_bet] } } }
      end      
      error_code = response.to_hash[:place_bets_response][:result][:error_code]
  		return error_code == 'OK' ? response.to_hash[:place_bets_response][:result][:bet_results][:place_bets_result] : error_code  		
    end

    def cancel_bet(exchange_id, bet_id)
      response = exchange(exchange_id).request :bf, :cancelBets do
        soap.body = { 'bf:request' => { :header => api_request_header, :bets => { 'CancelBets' => [{ :betId => bet_id }] } } } # "CancelBets" has to be a string, not a symbol!
      end		
      error_code = response.to_hash[:cancel_bets_response][:result][:error_code]
  		return error_code == 'OK' ? response.to_hash[:cancel_bets_response][:result][:bet_results][:cancel_bets_result] : error_code
    end
        
  	def get_market(exchange_id, market_id)
  		response = exchange(exchange_id).request :bf, :getMarket do
  			soap.body = { 'bf:request' => { :header => api_request_header, :marketId => market_id } }
  		end
  		error_code = response.to_hash[:get_market_response][:result][:error_code]
  		return error_code == 'OK' ? response.to_hash[:get_market_response][:result][:market] : error_code
  	end
    
    def get_market_prices_compressed(exchange_id, market_id, currency_code = nil)
      response = exchange(exchange_id).request :bf, :getMarketPricesCompressed do
       soap.body = { 'bf:request' => { :header => api_request_header,  :marketId => market_id, :currencyCode => currency_code } }
      end
      error_code = response.to_hash[:get_market_prices_compressed_response][:result][:error_code]      
      return error_code == 'OK' ? response.to_hash[:get_market_prices_compressed_response][:result][:market_prices] : error_code
    end
            
    def get_all_markets(exchange_id, event_type_ids = nil, locale = nil, countries = nil, from_date = nil, to_date = nil)
      response = exchange(exchange_id).request :bf, :getAllMarkets do
        soap.body = { 'bf:request' => { :header => api_request_header, 
                                        :eventTypeIds => { 'int' => event_type_ids }, 
                                        :locale => locale, :countries => { 'country' => countries}, 
                                        :fromDate => from_date, 
                                        :toDate => to_date 
                                      } 
                    }
      end            
      error_code = response.to_hash[:get_all_markets_response][:result][:error_code]      
      return error_code == 'OK' ? response.to_hash[:get_all_markets_response][:result][:market_data] : error_code      
    end
                  
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
      
      response_header = response.to_hash[:login_response][:result][:header]
      @error_code = response_header[:error_code]
      @session_token = (response_header[:error_code].to_s === 'OK') ? response_header[:session_token].to_s : nil
    end
      
    def exchange(exchange_id)   
      exchange_id == 2  ? @aus_service : @uk_service
    end

    def api_request_header      
      { :client_stamp => 0, :session_token => @session_token }
    end

    # 3/ refactor later to read from base64 encoded ~/.betfair/auth
  	def initialize(options = {})
      
      config = { :proxy => nil,
                 :logging => nil,
                 :username => nil,
                 :password => nil,
                 :product_id => 82,
                 :vendor_software_id => 0,
                 :location_id => 0,
                 :ip_address => nil
                 }.merge!(options)
    
      proxy = config[:proxy]
      logging = config[:logging]
      
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

      if (config[:username] && config[:password]) then
        self.login(config[:username], config[:password], config[:product_id], config[:vendor_software_id], config[:location_id], config[:ip_address])
      end
      
  	end
      
  end
  
end