require 'rubygems'

require 'betfair'
require 'etc' 
require 'ostruct'

auth = IO.read(Etc.getpwuid.dir + '/.betfair/auth')

mid = ARGV[0]
interval = 10

bf = Betfair::API.new({ :credentials => auth, :logging => false })  
helpers = Betfair::Helpers.new

while 1
  
  data = bf.get_market_prices_compressed(1, mid)
  
  data.split(':').drop(1).each do |runner|

      info = OpenStruct.new

      runner.split('|').shift.each do |information|

        tokens = information.split(/~/)

        info.SelectionID = tokens[0]
        info.OrderIndex = tokens[1]
        info.TotalAmountMatched = tokens[2]
        info.LastPriceMatched = tokens[3]
        info.DoubleHandicap = tokens[4]
        info.DoubleReductionFactorReduction = tokens[5]
        info.BooleanVacantUsed = tokens[6]
        info.AsianLineId = tokens[7]
        info.FarSPPrice = tokens[8]
        info.NearSPPrice = tokens[9]
        info.ActualSPPrice = tokens[10]

      end

      runner.split('|').drop(1).each do |information|

          prices = information.split(/~/)

          price = OpenStruct.new
          price.Odds = prices[0]
          price.TotalAvailable = prices[1]
          price.Type = (prices[2] === 'B') ? 'BACK' : 'LAY'
          price.Unknown = prices[3]

          puts "\"#{Time.now.iso8601}\":"
          puts "  - Type: #{price.Type}"            
          puts "    TotalAvailable: #{price.TotalAvailable}"            
          puts "    Price: #{price.Odds}"
          puts "    Selection: #{info.SelectionID}"
      
      end

  end

  # ruby seems to keep _puts_ output in a buffer when inside a while loop and STDOUT to a file
  #  so we forcibly flush it 
  STDOUT.flush
  
  sleep interval

end 
