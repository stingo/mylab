class FilterCurrency
  def initialize(currency_code)
    @currency_code = currency_code # initialize the currency code
    @default_currency = "USD" # Set the default currency
    @supported_currencies = %w[USD PHP EUR JPY] # Add the currencies you want supported here (currencies in the dropdown menu of the application)
  end

  def perform
    return @default_currency unless @supported_currencies.include? @currency_code

    @currency_code
  end
end
