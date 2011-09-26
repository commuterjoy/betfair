require 'savon'
require Pathname.new(__FILE__).dirname + 'betfair/version'
require Pathname.new(__FILE__).dirname + 'betfair/general'
require Pathname.new(__FILE__).dirname + 'betfair/read'
require Pathname.new(__FILE__).dirname + 'betfair/bet'
require Pathname.new(__FILE__).dirname + 'betfair/account'

# bf = Betfair::General.new()
# session_token = bf.login('lukebyrne', 'm3d1ap0d', 82, 0, 0, nil)