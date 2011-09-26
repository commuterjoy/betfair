module Betfair
 ############################################
 ## Read Only Betting API Services Reference
 ############################################
 class Read
     
   # conversion = api.convert_currency(session_token, 20.00, 'AUD', 'UK')
   # conversion.to_hash[:convert_currency_response]
   def convert_currency(session_token, amount, from_currency, to_currency)
     global.request :bf, :convertCurrency do 
       soap.body = { 'bf:request' => { :header => api_request_header(session_token), :amount => amount, :fromCurrency => from_currency, :toCurrency => to_currency } }
     end
   end
 
   # SERVICE_NOT_AVAILABLE_IN_PRODUCT
   # active_event_types = api.get_active_event_types(session_token)
   # active_event_types.to_hash[:get_active_event_types_response]
   def get_active_event_types(session_token, locale = nil)
     global.request :bf, :getActiveEventTypes do 
       soap.body = { 'bf:request' => { :header => api_request_header(session_token), :locale => locale } }
     end	
   end
 
   # SERVICE_NOT_AVAILABLE_IN_PRODUCT
   # all_currencies = api.get_all_currencies(session_token)
   # all_currencies.to_hash[:get_all_currencies_response]
   def get_all_currencies(session_token)
     global.request :bf, :getAllCurrencies do 
       soap.body = { 'bf:request' => { :header => api_request_header(session_token) } }
     end
   end

   # SERVICE_NOT_AVAILABLE_IN_PRODUCT
   # all_currencies = api.get_all_currenciesV2(session_token)
   # all_currencies.to_hash[:get_all_currencies_v2_response]
   def get_all_currenciesV2(session_token)
     global.request :bf, :getAllCurrenciesV2 do 
       soap.body = { 'bf:request' => { :header => api_request_header(session_token) } }
     end	
   end
 
   # all_event_types = api.get_all_event_types(session_token)
   # all_event_types.to_hash[:get_all_event_types_response]
   def get_all_event_types(session_token, locale = nil)
     global.request :bf, :getAllEventTypes do 
       soap.body = { 'bf:request' => { :header => api_request_header(session_token), :locale => locale } }
     end
   end

   # markets = api.get_all_markets(session_token, 1, nil, [1,3], nil, nil, nil)
   # markets.to_hash[:get_all_markets_response]
   # markets.to_hash[:get_all_markets_response][:result][:market_data].split(':').each do |market|
   #		puts '------------------------'
   # 	puts market.to_s.split('~')
   # end
   def get_all_markets(session_token, exchange_id, locale = nil, event_type_ids = nil, countries = nil, from_date = nil, to_date = nil)
     exchange(exchange_id).request :bf, :getAllMarkets do
       soap.body = { 'bf:request' => { :header => api_request_header(session_token),  :locale => locale, :eventTypeIds => event_type_ids, :countries => nil, :fromDate => from_date, :toDate => to_date } }
     end
   end

   def get_bet
     raise 'See get bet lite'	
   end

   def get_bet_history
     raise 'To Do'
   end

   def get_bet_lite(session_token, exchange_id, bet_id)
 		exchange(exchange_id).request :bf, :getBetLite do
 			soap.body = { 'bf:request' => { :header => api_request_header(session_token), :betId => bet_id } }
 		end
 	end

   def get_bet_matches_lite
     raise 'To Do'
   end
 
   # complete_market_prices_compressed = api.get_complete_market_prices_compressed(session_token, 1, nil, 102458421)
   # complete_market_prices_compressed.to_hash[:get_complete_market_prices_compressed_response]
   def get_complete_market_prices_compressed(session_token, exchange_id, currency_code, market_id)
     exchange(exchange_id).request :bf, :get_complete_market_prices_compressed do
       soap.body = { 'bf:request' => { :header => api_request_header(session_token), :currencyCode => currency_code, :marketId => market_id } }
     end
   end

   def get_current_bets
     raise 'To Do'
   end

   def get_current_bets_lite
     raise 'To Do'
   end

   def get_detail_available_market_depth
     raise 'To Do'
   end

   def get_events
     raise 'To Do'
   end

   def get_in_play_markets
     raise 'To Do'
   end

   # market = api.get_market(session_token, 1, 102458421)
   # market.to_hash[:get_market_response]
 	def get_market(session_token, exchange_id, market_id)
 		exchange(exchange_id).request :bf, :getMarket do
 			soap.body = { 'bf:request' => { :header => api_request_header(session_token), :marketId => market_id } }
 		end
 	end
	
   def get_market_info
     raise 'To Do'
   end
 
   # market_prices = api.get_market_prices(session_token, 1, nil, 102458421)
   # market_prices.to_hash[:get_market_prices_response]
   def get_market_prices(session_token, exchange_id, currency_code, market_id)
     exchange(exchange_id).request :bf, :getMarketPrices do
       soap.body = { 'bf:request' => { :header => api_request_header(session_token),  :currencyCode => currency_code, :marketId => market_id } }
     end
   end
 
   # market_prices_compressed = api.get_market_prices_compressed(session_token, 1, nil, 102458421)
   # market_prices_compressed.to_hash[:get_market_prices_compressed_response]
   def get_market_prices_compressed(session_token, exchange_id, currency_code, market_id)
     exchange(exchange_id).request :bf, :getMarketPricesCompressed do
      soap.body = { 'bf:request' => { :header => api_request_header(session_token),  :currencyCode => currency_code, :marketId => market_id } }
     end
   end

   def get_macthed_and_unmatched_bets
     raise 'To Do'
   end
 
   def get_mu_bets
 		raise 'To Do'
 	end

   def get_macthed_and_unmatched_bets_lite
     raise 'To Do'
   end
 
   def get_profit_and_loss
     raise 'To Do'
   end

   def get_market_traded_volume
     raise 'To Do'
   end

   def get_market_traded_volume_compressed
     raise 'To Do'
   end

   def get_private_markets
     raise 'To Do'
   end

   def get_silks
     raise 'To Do'
   end

   def get_silksV2
     raise 'To Do'
   end
 end
end