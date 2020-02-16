class AddAttributesToUser < ActiveRecord::Migration[6.0]
  def change

  	add_column :users, :admin, :boolean, default: false
  	add_column :users, :slug, :string
  	add_column :users, :username, :string
  	add_column :users, :first_name, :string
  	add_column :users, :last_name, :string


    add_index :users, :username
    add_index :users, :slug
  end
end
