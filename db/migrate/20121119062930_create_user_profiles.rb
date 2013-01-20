class CreateUserProfiles < ActiveRecord::Migration
  def change
    create_table :user_profiles do |t|
      t.string :full_name
      t.text :about
      t.string :mobile_no
      t.string :location
      t.references :user

      t.timestamps
    end
    add_foreign_key(:user_profiles, :users)
  end
end
