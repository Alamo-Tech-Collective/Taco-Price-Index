class CreateUserFavorites < ActiveRecord::Migration[7.0]
  def change
    create_table :user_favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.uuid :restaurant_id, null: false

      t.timestamps
    end

    add_foreign_key :user_favorites, :restaurants, column: :restaurant_id
    add_index :user_favorites, [ :user_id, :restaurant_id ], unique: true
  end
end
