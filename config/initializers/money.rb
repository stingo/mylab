require "money"
require "money/bank/google_currency"

MoneyRails.configure do |config|
  config.default_currency = :usd

  Money::Bank::GoogleCurrency::SERVICE_HOST = "finance.google.com".freeze

  # set default bank to instance of GoogleCurrency
  Money::Bank::GoogleCurrency.ttl_in_seconds = 86_400
  config.default_bank = Money::Bank::GoogleCurrency.new
end
