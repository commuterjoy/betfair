require 'savon'
require 'betfair/version'
require 'betfair/api'
require 'betfair/helpers'

# prevents rogue debug output from HTTPI
# - http://stackoverflow.com/questions/5009838/httpi-tried-to-user-the-httpi-adapter-error-using-savon-soap-library
HTTPI.log = false
