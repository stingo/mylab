class RenameLocationToCurrencyInUser < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :location, :currency
  end
end
