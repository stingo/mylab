class AddCurrencyReferenceToAds < ActiveRecord::Migration[6.0]
  def up
    add_reference :ads, :currency, default: 1, null: false, foreign_key: true
  end

  def down
    remove_reference :ads, :currency
  end
end
