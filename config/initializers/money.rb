require "money"
require "money/bank/currencylayer_bank"

MoneyRails.configure do |config|
  config.default_currency = :usd

  mclb = Money::Bank::CurrencylayerBank.new
  mclb.access_key = "9e2fbbe64e3c0868487eaa5883c97d22"
  mclb.ttl_in_seconds = 86_400
  mclb.update_rates

  config.default_bank = mclb
end
