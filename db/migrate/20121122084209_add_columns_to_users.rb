class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :crypted_password, :string

    add_column :users, :persistence_token, :string

  end
end
