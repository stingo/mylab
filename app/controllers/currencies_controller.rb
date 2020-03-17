class CurrenciesController < ApplicationController
  def index
    @currencies = Currency.all
  end
end
