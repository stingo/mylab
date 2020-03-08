module AdsHelper
  def converted_price(price)
    Money.default_bank.update_rates
    
    if session[:currency].present?
      humanized_money_with_symbol(Money.default_bank.exchange_with(price, session[:currency]))
    else
      humanized_money_with_symbol(price)
    end
  end
end
