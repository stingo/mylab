class AddDeliveryOnAds < ActiveRecord::Migration[6.0]
  def change
    add_monetize :ads, :delivery
  end
end
