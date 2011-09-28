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
  	
  	def mash(session_token, exchange_id, market_id)
       bf = Betfair::API.new
       combine( bf.get_all_markets(session_token, exchange_id, market_id), bf.get_market_prices_compressed(session_token, exchange_id, market_id) )
  	end
  	
  	def market_info(details)
  	  { :exchange_id => nil,
  	    :market_type_id => nil,
  	    :market_matched => nil,
  	    :menu_path => details[:menu_path], 
  	    :market_id => details[:market_id], 
  	    :market_name => details[:name],
  	    :market_type_name => details[:menu_path].to_s.split('\\')[1]
  	  }
  	end
  	
  	def combine(market, prices)
  	  market = details(market)            
  	  prices = prices(prices)
			market[:runners].each do |runner|
				runner.merge!({ :market_type_id => market[:market_type_id] })
				runner.merge!(price_string(prices[runner[:id]]))
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
  	
  	def price_string(string)
  	  string_raw = string
  	  string = string.split('|')
  	  price = { }        			
		  
			if !string[0].nil?
			  str = string[0].split('~')	
			  price[:prices_string] = string_raw
				price[:runner_matched] = str[2].to_f
				price[:last_back_price]   = str[3].to_f
			end
		  
		  # Get the b prices (which are actually the l prices)
			if !string[1].nil?
			  b = string[1].split('~')	
				price[:b1]             = b[0].to_f if !b[0].nil?
				price[:b1_available]   = b[1].to_f if !b[1].nil?
				price[:b2]             = b[4].to_f if !b[5].nil?
				price[:b2_available]   = b[5].to_f if !b[6].nil?
				price[:b3]             = b[8].to_f if !b[8].nil?
				price[:b3_available]   = b[9].to_f if !b[9].nil?  				 				
				combined_b = price[:b1] + price[:b2] + price[:b3]
			end				
		 
		  # Get the l prices (which are actually the l prices)
			if !string[2].nil?
			  l = string[2].split('~')
				price[:l1]             = l[0].to_f if !l[0].nil?
				price[:l1_available]   = l[1].to_f if !l[1].nil?
				price[:l2]             = l[4].to_f if !l[4].nil?
				price[:l2_available]   = l[5].to_f if !l[5].nil?
				price[:l3]             = l[8].to_f if !l[8].nil?
				price[:l3_available]   = l[9].to_f if !l[9].nil?  				  				
				combined_l = price[:l1] + price[:l2] + price[:l3]
			end			
			price[:wom] = combined_b / ( combined_b + combined_l ) if !combined_b.nil? and !combined_l.nil?
			return price			  		
  	end

  end
	  
end