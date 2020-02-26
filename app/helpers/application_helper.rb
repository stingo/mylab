module ApplicationHelper
  def converted_price(price)
    if session[:currency].present?
      humanized_money_with_symbol(price.exchange_to(session[:currency]))
    else
      humanized_money_with_symbol(price)
    end
  end
end
