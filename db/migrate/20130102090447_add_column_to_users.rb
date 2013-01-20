class AddColumnToUsers < ActiveRecord::Migration
  def change

    add_column :users, :perishable_token, :string

    add_column :users, :verified, :boolean, :default => false

  end
end
