class RestaurantsController < ApplicationController
  before_action :require_authentication, except: %i[ index show map_test ]
  before_action :set_restaurant, only: %i[ show edit update destroy toggle_favorite ]

  def index
    @restaurants = Restaurant.all
  end

  def map_test
    # This is a test action for debugging the map
    render "map_test", layout: false
  end

  def show
    @restaurant = Restaurant.find(params[:id])

    # Get all reviews (both app and Google reviews)
    @reviews = @restaurant.reviews
                         .includes(:user)
                         .order(created_at: :desc)
                         .limit(10) # Limit to 10 most recent reviews

    # Calculate average rating from both review types
    @app_rating = @restaurant.reviews.where.not(fullness_rating: nil).average(:fullness_rating)
    @google_rating = @restaurant.google_rating

    # Calculate combined average if we have both types of ratings
    @average_rating = if @app_rating && @google_rating
                       ((@app_rating + @google_rating) / 2.0).round(1)
    else
                       (@app_rating || @google_rating)&.round(1)
    end

    # Get tacos with their photos
    @tacos = @restaurant.tacos
                      .includes(photos_attachments: :blob)
                      .order(created_at: :desc)

    # Filter in Ruby to avoid UUID/string comparison issues
    @tacos = @tacos.select { |taco| taco.photos.attached? } if @tacos.any?(&:photos_attached?)

    # Prepare map data
    @markers = [ {
      id: @restaurant.id.to_s,
      lat: @restaurant.latitude.to_f,
      lng: @restaurant.longitude.to_f,
      name: @restaurant.name,
      address: [ @restaurant.street_address, @restaurant.city, @restaurant.state, @restaurant.zip ].compact.join(", "),
      url: restaurant_path(@restaurant),
      favorite_count: @restaurant.favorite_count,
      is_favorite: Current.user ? @restaurant.favorite_for?(Current.user) : false,
      rating: @average_rating
    } ].compact

    Rails.logger.debug "Prepared markers: #{@markers.inspect}"

    # Set map center to restaurant location
    @map_center = {
      lat: @restaurant.latitude.to_f,
      lng: @restaurant.longitude.to_f
    }

    Rails.logger.debug "Map center: #{@map_center.inspect}"

    # For new review form
    @review = @restaurant.reviews.new
  end

  def new
    @restaurant = Restaurant.new
  end

  def edit
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    if @restaurant.save
      redirect_to @restaurant, notice: "Restaurant was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @restaurant.update(restaurant_params)
      redirect_to @restaurant, notice: "Restaurant was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_favorite
    if Current.user.nil?
      return render json: { error: "Not authenticated" }, status: :unauthorized
    end

    if Current.user.favorite?(@restaurant)
      Current.user.user_favorites.find_by(restaurant: @restaurant).destroy
      is_favorite = false
    else
      Current.user.user_favorites.create(restaurant: @restaurant)
      is_favorite = true
    end

    render json: {
      favorite_count: @restaurant.reload.user_favorites.count,
      is_favorite: is_favorite
    }
  end

  def destroy
    @restaurant.destroy
    redirect_to restaurants_url, notice: "Restaurant was successfully destroyed."
  end

  private
    def set_restaurant
      @restaurant = Restaurant.find(params[:id])
    end

    def restaurant_params
      params.require(:restaurant).permit(
        :name,
        :street_address,
        :city,
        :state,
        :zip,
        :phone,
        :website,
        :description,
        :latitude,
        :longitude,
        :yelp_id,
        :google_rating,
        :google_price_level,
        :google_user_ratings_total,
        :business_hours
      )
    end
end
