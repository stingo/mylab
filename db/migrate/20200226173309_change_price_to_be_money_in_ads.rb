class ChangePriceToBeMoneyInAds < ActiveRecord::Migration[6.0]
  def change
    remove_column :ads, :price
    add_monetize :ads, :price
  end
end
