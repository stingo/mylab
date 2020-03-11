class FilterCurrency
  def initialize(currency_code)
    default_currency = "USD"
    supported_currencies = %w[USD PHP EUR JPY] # Add the currencies you want supported here (currencies in the dropdown menu of the application)

    if supported_currencies.include? currency_code
      currency_code
    else
      default_currency
    end
  end
end
