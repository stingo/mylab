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
require 'test_helper'

class AdTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
