class CurrenciesController < ApplicationController
  def index
    @currencies = Currency.all
  end

  def show
    @currency = Currency.find(params[:id])
    @ads = Ad.all.currency_ads(currency.iso_code)
  end
end
