class AddUserFavoritesCountToRestaurants < ActiveRecord::Migration[8.0]
  def up
    add_column :restaurants, :user_favorites_count, :integer, default: 0, null: false
    add_index :restaurants, :user_favorites_count

    # Backfill existing data
    Restaurant.find_each do |restaurant|
      Restaurant.reset_counters(restaurant.id, :user_favorites)
    end
  end

  def down
    remove_column :restaurants, :user_favorites_count
  end
end
