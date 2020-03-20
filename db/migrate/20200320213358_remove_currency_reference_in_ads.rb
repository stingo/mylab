class RemoveCurrencyReferenceInAds < ActiveRecord::Migration[6.0]
  def up
    ActiveRecord::Base.transaction do
      Ad.all.each do |ad|
        currency = Currency.find_by(id: ad.currency_id)
        ad.update(price_currency: currency.iso_code)
      end
    end

    remove_reference :ads, :currency
  end

  def down
    add_reference :ads, :currency, default: 1, null: false, foreign_key: true

    ActiveRecord::Base.transaction do
      Ad.all.each do |ad|
        price_currency = Currency.find_by(iso_code: ad.price_currency)
        ad.update(currency: price_currency.id)
      end
    end
  end
end
