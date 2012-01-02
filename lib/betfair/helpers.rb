module Betfair

  class Helpers  	  	
	
  	def market_info(details)
  	  runners = []
  	  details[:runners][:runner].each { |runner| runners << { :runner_id => runner[:selection_id].to_i, :runner_name => runner[:name] } }
  	  { :exchange_id => nil,
  	    :market_type_id => nil,
  	    :market_matched => nil,
  	    :menu_path => details[:menu_path], 
  	    :market_id => details[:market_id], 
  	    :market_name => details[:name],
  	    :market_type_name => details[:menu_path].to_s.split('\\')[1],
  	    :runners => runners
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
