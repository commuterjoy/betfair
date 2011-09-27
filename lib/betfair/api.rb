module Betfair
  
  class API
        
  	def get_market(session_token, exchange_id, market_id)
  		response = exchange(exchange_id).request :bf, :getMarket do
  			soap.body = { 'bf:request' => { :header => api_request_header(session_token), :marketId => market_id } }
  		end

  		error_code = response.to_hash[:get_market_response][:result][:error_code]
  		error_code == 'OK' ? response.to_hash[:get_market_response][:result][:market] : error_code
  	end
    
    def get_market_prices_compressed(session_token, exchange_id, market_id, currency_code = nil)
      response = exchange(exchange_id).request :bf, :getMarketPricesCompressed do
       soap.body = { 'bf:request' => { :header => api_request_header(session_token),  :marketId => market_id, :currencyCode => currency_code } }
      end
      error_code = response.to_hash[:get_market_prices_compressed_response][:result][:error_code]      
      return error_code == 'OK' ? response.to_hash[:get_market_prices_compressed_response][:result][:market_prices] : error_code
    end
            
    def get_all_markets(session_token, exchange_id, event_type_ids = nil, locale = nil, countries = nil, from_date = nil, to_date = nil)
      response = exchange(exchange_id).request :bf, :getAllMarkets do
        soap.body = { 'bf:request' => { :header => api_request_header(session_token), 
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
      
      session_token(response.to_hash[:login_response][:result][:header])       
    end
      
    def exchange(exchange_id)   
      exchange_id == 2  ? @aus_service : @uk_service
    end

    def api_request_header(session_token)      
      { :client_stamp => 0, :session_token => session_token }
    end
    
    def session_token(response_header)      
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
  
  class Helpers  	
  	
  	def combine(market, prices)
  	  market = details(market)            
  	  prices = prices(prices)
			market[:runners].each do |runner|
				p = { :prices => prices[runner[:id]] }
				runner.merge!(p)
			end
  	end
  	
		def details(market)
			runners = []
			market[:runners][:runner].each { |runner| runners << { :id => runner[:selection_id].to_i, :name => runner[:name] } }
			return { :market_type_id => market[:event_type_id].to_i, :runners => runners }
	  end

  	def prices(prices)
			price_hash = {}					
			prices.gsub! '\:', "\0"
			pieces = prices.split ":"
			pieces.each do |piece|
				piece.gsub! "\0", '\:'
				price_hash[piece.split('~')[0].to_i] = piece
			end
			return price_hash
  	end
  	
  end
	  
end