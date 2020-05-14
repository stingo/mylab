class AddDeliveryOnAds < ActiveRecord::Migration[6.0]
  def change
    add_monetize :products, :delivery 
  end
end
