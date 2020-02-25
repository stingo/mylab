# == Schema Information
#
# Table name: ads
#
#  id          :bigint           not null, primary key
#  title       :string
#  description :text
#  image       :string
#  user_id     :integer
#  slug        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  price       :decimal(, )
#
class Ad < ApplicationRecord
  belongs_to :user

  extend FriendlyId
  friendly_id :title, use: :slugged

  def should_generate_new_friendly_id?
    title_changed?
  end
end
