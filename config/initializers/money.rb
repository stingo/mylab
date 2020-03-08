require "money"
require "eu_central_bank"

MoneyRails.configure do |config|
  config.default_currency = :usd
  Money.default_bank = EuCentralBank.new
end
