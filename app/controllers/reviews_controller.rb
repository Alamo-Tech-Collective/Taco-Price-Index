class ReviewsController < ApplicationController
  before_action :require_authentication
  before_action :set_restaurant
  before_action :set_review, only: %i[show edit update destroy]

  def index
    @reviews = Review.all
  end

  def show
  end

  def new
    @review = @restaurant.reviews.build
  end

  def edit
  end

  def create
    @review = @restaurant.reviews.build(review_params)
    @review.user = current_user
    # Set the display author name based on the logged-in user
    if current_user
      @review.author_name = current_user.respond_to?(:username) ? current_user.username : (current_user.respond_to?(:name) ? current_user.name : (current_user.respond_to?(:email_address) ? current_user.email_address : current_user.email))
    end
    if @review.save
      redirect_to restaurant_path(@restaurant), notice: "Review was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @review.update(review_params)
      redirect_to [ @restaurant, @review ], notice: "Review was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    redirect_to restaurant_path(@restaurant), notice: "Review was successfully destroyed."
  end

  private
    def set_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end
    def set_review
      @review = Review.find(params[:id])
    end

    def review_params
      params.require(:review).permit(
        :restaurant_id,

        :author_url,
        :google_rating,
        :fullness_rating,
        :content,
        :review_date,
        :language,
        photos: []
      )
    end
end
