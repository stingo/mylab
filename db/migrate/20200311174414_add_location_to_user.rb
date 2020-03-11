class AddLocationToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :location, :string, default: nil, allow_nil: true
  end
end
