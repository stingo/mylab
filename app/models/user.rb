# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  admin                  :boolean          default("false")
#  slug                   :string
#  username               :string
#  first_name             :string
#  last_name              :string
#  country                :string
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :ads, dependent: :destroy
  has_many :articles, dependent: :destroy

  def full_name
    "#{first_name} #{last_name}"
  end

  extend FriendlyId
  friendly_id :username, use: :slugged

  def should_generate_new_friendly_id?
    username_changed?
  end

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  # validates :country, :presence => true

  # validates :location_id, :presence => {:message => ': Please select Country of location '}
  # validates :town, :presence => true

  # validates :displayname, :presence => true, :length => { :maximum => 50 }
  validates :username, format: { with: /\A[a-zA-Z0-9]+\Z/ }, length: { minimum: 3, maximum: 50 }, uniqueness: true
end
