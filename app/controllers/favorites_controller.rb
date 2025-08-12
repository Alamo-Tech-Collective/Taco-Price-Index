class FavoritesController < ApplicationController
  before_action :require_authentication

  def toggle
    restaurant = Restaurant.find(params[:restaurant_id])
    current_user.toggle_favorite(restaurant)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update(
            "favorite-#{restaurant.id}",
            partial: "frontend_pages/favorite_button",
            locals: { restaurant: restaurant }
          ),
          turbo_stream.update(
            "favorite-count-#{restaurant.id}",
            partial: "frontend_pages/favorite_count",
            locals: { restaurant: restaurant }
          )
        ]
      end
    end
  end

  def index
    @favorite_restaurants = current_user.favorite_restaurants
  end
end
