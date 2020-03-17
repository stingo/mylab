class CreateCurrency < ActiveRecord::Migration[6.0]
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :country
      t.string :iso_code
      t.string :website
    end
  end
end
