require "money/bank/currencylayer_bank"

MoneyRails.configure do |config|
  bank = Money::Bank::CurrencylayerBank.new
  bank.access_key = "749ea9046a7bd8b11d3e155d0acfdb19"
  bank.source = "USD"
  bank.ttl_in_seconds = 86_400
  bank.cache = proc do |v|
    key = "money:currencylayer_bank"
    if v
      Thread.current[key] = v
    else
      Thread.current[key]
    end
  end

  config.default_bank = bank
end
