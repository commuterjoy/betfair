
require 'rubygems'
require 'betfair'
require 'etc' 
require 'ostruct'

auth = IO.read(Etc.getpwuid.dir + '/.betfair/auth')

events = (ARGV.first) ? ARGV.first.split(',') : [3]

bf = Betfair::API.new({ :logging => false, :credentials => auth })  
helpers = Betfair::Helpers.new

markets = bf.get_all_markets(1, events, nil, nil, nil, nil).split(':')

# Loop though the markets array
markets.each do |market| 
  
    tokens = market.split('~')

    market = OpenStruct.new
    market.mid = tokens[0]
    market.name = tokens[1]
    market.type = tokens[2]
    market.status = tokens[3]
    market.date = tokens[4]
    market.path = tokens[5]    
    market.hierarchy = tokens[6]
    market.delay = tokens[7]
    market.exchange_id = tokens[8]
    market.country = tokens[9]
    market.last_refresh = tokens[10]
    market.runners = tokens[11]    
    market.winners = tokens[12]
    market.matched = tokens[13]
    market.bsp = tokens[14]
    market.in_play = tokens[15]

    puts "#{market.mid} #{market.path} #{market.name}"
    
end
