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

      self.login(config[:username], config[:password], config[:product_id], config[:vendor_software_id], config[:location_id], config[:ip_address])
  	end
      
  end
  
  class Helpers  	  	
  	
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
				runner.merge!(price_string(prices[runner[:runner_id]]))
			end
  	end
  	  	  	  	
		def details(market)
			runners = []
			market[:runners][:runner].each { |runner| runners << { :runner_id => runner[:selection_id].to_i, :runner_name => runner[:name] } }
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

  	  price = { :prices_string => nil, :runner_matched => 0, :last_back_price => 0, :wom => 0, 
		             :b1 => 0, :b1_available => 0, :b2 => 0, :b2_available => 0, :b3 => 0, :b3_available => 0,
		             :l1 => 0, :l1_available => 0, :l2 => 0, :l2_available => 0, :l3 => 0, :l3_available => 0 
		          }    			
		  
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
				combined_b = price[:b1_available] + price[:b2_available] + price[:b3_available]
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
				combined_l = price[:l1_available] + price[:l2_available] + price[:l3_available]
			end			
			price[:wom] = combined_b / ( combined_b + combined_l )
			return price			  		
  	end

  end
	  
end