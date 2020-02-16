class CreateAds < ActiveRecord::Migration[6.0]
  def change
    create_table :ads do |t|
      t.string :title
      t.text :description
      t.string :image
      t.integer :user_id
      t.string :slug

      t.timestamps
    end
  end
end


