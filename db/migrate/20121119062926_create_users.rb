class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_name
      t.string :email_id
      t.string :password_hash
      t.string :password_salt
      t.integer :user_type

      t.timestamps
    end
  end
end
