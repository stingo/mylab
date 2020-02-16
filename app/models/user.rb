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


          validates :first_name, :presence => true, :length => { :maximum => 50 }
          validates :last_name, :presence => true, :length => { :maximum => 50 }
          #validates :country, :presence => true

          #validates :location_id, :presence => {:message => ': Please select Country of location '}
          #validates :town, :presence => true
        

          
          #validates :displayname, :presence => true, :length => { :maximum => 50 }
          validates :username, format: { with: /\A[a-zA-Z0-9]+\Z/ }, length: {minimum: 3, maximum: 50}, uniqueness: true

end
