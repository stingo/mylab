require 'money'
require 'money/bank/google_currency'
require 'json'

MultiJson.engine = :json_gem
Money.default_bank = Money::Bank::GoogleCurrency.new
