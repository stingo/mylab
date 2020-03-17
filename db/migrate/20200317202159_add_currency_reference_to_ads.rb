class AddCurrencyReferenceToAds < ActiveRecord::Migration[6.0]
  def up
    add_reference :ads, :currency, foreign_key: true
  end

  def down
    add_reference :ads, :currency, foreign_key: true
  end
end
