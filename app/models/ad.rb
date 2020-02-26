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

  extend FriendlyId
  friendly_id :title, use: :slugged

  monetize :price_cents

  def price
    Money.new price_cents, price_currency
  end

  def price=(value)
    value = Money.parse(value) if value.instance_of? String # otherwise assume, that value is a Money object

    self[:price_cents] = value.cents
    self[:price_currency] = value.currency_as_string
  end

  def should_generate_new_friendly_id?
    title_changed?
  end
end
