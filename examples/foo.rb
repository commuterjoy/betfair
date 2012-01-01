
require 'rubygems'
require 'betfair'
require 'etc' 

# Eg, somewhere with a base64 encoded username and password string
auth_file = Etc.getpwuid.dir + '/.betfair/auth'

# either read the authentication tokens from a file, or default to using 'username|password'
auth = (File.exists?(auth_file)) ? IO.read(auth_file) : 'dXNlcm5hbWV8cGFzc3dvcmQ='

bf = Betfair::API.new({:logging => true, :credentials => auth})  
helpers = Betfair::Helpers.new

# This call just returns back a huge string, markets ar edeliminated by ':', run the split method to convert string to a array
markets = bf.get_all_markets(1, [1,3], nil, nil, nil, nil).split(':')

# Loop though the markets array
markets.each do |market| 
  
  # Once we have a market then the fields with in this are delimnated by '~', run the split method to convert string to a array
  market = market.split('~')
  
  market_id = market[0]
  market_name = market[1].to_s
  menu_path = market[5]
  
  # Now lets just look for Match Odds for Tottenham for the English Premier League
  if market_name == 'Match Odds' and menu_path.include? 'Barclays Premier League' and menu_path.include? 'Tottenham'
    # Run the API call to get the Market Info
    puts bf.get_market(1, market_id)
    # Run the API call to get the prices
    puts bf.get_market_prices_compressed(1, market_id)
  end
  
end