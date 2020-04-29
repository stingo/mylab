# == Schema Information
#
# Table name: ads
#
#  id             :bigint           not null, primary key
#  title          :string
#  description    :text
#  image          :string
#  user_id        :integer
#  slug           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  price_cents    :integer          default("0"), not null
#  price_currency :string           default("USD"), not null
#
class Ad < ApplicationRecord
  belongs_to :user
  has_one :currency

  def self.currency_ads(currency_code)
    where(price_currency: currency_code)
  end

  extend FriendlyId
  friendly_id :title, use: :slugged

  monetize :price_cents

  def price
    Money.new price_cents, price_currency
  end

  def should_generate_new_friendly_id?
    title_changed?
  end
end
