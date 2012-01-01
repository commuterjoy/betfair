require 'Base64'

module Betfair
  
  class API
    
    attr_accessor :session_token, :error_code
  
  	def initialize(options = {})
      
      config = { :proxy => nil,
                 :logging => nil,
                 :credentials => nil,
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

      if (config[:credentials]) then
        auth = self.decode_credentials(config[:credentials])
        self.login(auth[:username], auth[:password], config[:product_id], config[:vendor_software_id], config[:location_id], config[:ip_address])
      end
      
  	end

    def decode_credentials(auth_token)
      tokens = Base64.decode64(auth_token).split('|')
      auth = { :username => tokens[0], :password => tokens[1] } 
    end

    def exchange(exchange_id)   
      exchange_id == 2  ? @aus_service : @uk_service
    end

    def api_request_header      
      { :client_stamp => 0, :session_token => @session_token }
    end
        
    # generic interface between betfair API and our public methods
    def request(exchange_id, method, body)
        
      # make the soap request
      response = exchange(exchange_id).request :bf, method do
        soap.body = body
      end
      
      # derive the response object symbole - Eg, placeBets => place_bets_response
      response_name = (method.to_s.gsub(/([A-Z])/, '_\1').downcase + '_response').to_sym
      
      # assign response statuses
      response_header = response.to_hash[response_name][:result][:header]
      @session_token = (response_header[:error_code].to_s === 'OK') ? response_header[:session_token].to_s : nil
      @error_code = response.to_hash[response_name][:result][:error_code]
      
      response
    end
    
    def place_bet(exchange_id, market_id, runner_id, bet_type, price, size)
      bf_bet = { :marketId => market_id, :selectionId => runner_id, :betType => bet_type, :price => price, :size => size, :asianLineId => 0, :betCategoryType => 'E', :betPersistenceType => 'NONE', :bspLiability => 0 }      
      response = self.request(exchange_id, :placeBets, {
          'bf:request' => { :header => api_request_header, :bets => { 'PlaceBets' => [bf_bet] } } }
          )
  		return @error_code == 'OK' ? response.to_hash[:place_bets_response][:result][:bet_results][:place_bets_result] : @error_code
    end

    def cancel_bet(exchange_id, bet_id)
      response = self.request(exchange_id, :cancelBets, {
          'bf:request' => { :header => api_request_header, :bets => { 'CancelBets' => [{ :betId => bet_id }] } } }
          )
  		return @error_code == 'OK' ? response.to_hash[:cancel_bets_response][:result][:bet_results][:cancel_bets_result] : @error_code
    end
        
  	def get_market(exchange_id, market_id)
      response = self.request(exchange_id, :getMarket, {
          'bf:request' => { :header => api_request_header, :marketId => market_id } }
          )
  		return @error_code == 'OK' ? response.to_hash[:get_market_response][:result][:market] : @error_code
  	end
    
    def get_market_prices_compressed(exchange_id, market_id, currency_code = nil)
      response = self.request(exchange_id, :getMarketPricesCompressed, {      
        'bf:request' => { :header => api_request_header,  :marketId => market_id, :currencyCode => currency_code } }
        )
      return @error_code == 'OK' ? response.to_hash[:get_market_prices_compressed_response][:result][:market_prices] : @error_code
    end
            
    def get_all_markets(exchange_id, event_type_ids = nil, locale = nil, countries = nil, from_date = nil, to_date = nil)
      response = self.request(exchange_id, :getAllMarkets, {      
        'bf:request' => { :header => api_request_header, 
                                        :eventTypeIds => { 'int' => event_type_ids }, 
                                        :locale => locale, :countries => { 'country' => countries}, 
                                        :fromDate => from_date, 
                                        :toDate => to_date 
                                      } 
                    }
        )
      return @error_code == 'OK' ? response.to_hash[:get_all_markets_response][:result][:market_data] : @error_code      
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
      
  end
  
end