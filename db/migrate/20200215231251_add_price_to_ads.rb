class AddPriceToAds < ActiveRecord::Migration[6.0]
  def change
    add_column :ads, :price, :decimal
  end
end
