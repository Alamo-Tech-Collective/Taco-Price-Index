class UserFavorite < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant, counter_cache: :user_favorites_count

  validates :user_id, uniqueness: { scope: :restaurant_id }

  # Update the counter cache when a favorite is created or destroyed
  after_create :increment_counter_cache
  after_destroy :decrement_counter_cache

  private

  def increment_counter_cache
    Restaurant.increment_counter(:user_favorites_count, restaurant_id)
  end

  def decrement_counter_cache
    Restaurant.decrement_counter(:user_favorites_count, restaurant_id)
  end
end
