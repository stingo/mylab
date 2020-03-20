module AdsHelper
  def converted_price(price)
    MoneyRails.default_bank.update_rates if MoneyRails.default_bank.expired?

    if session[:currency].present?
      humanized_money_with_symbol(Money.default_bank.exchange_with(price, session[:currency]))
    else
      humanized_money_with_symbol(price)
    end
  end
end
