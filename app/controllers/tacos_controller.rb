class TacosController < ApplicationController
  before_action :require_authentication
  before_action :set_taco, only: %i[show edit update destroy]

  def index
    @tacos = Taco.all
  end

  def show
  end

  def new
    @taco = Taco.new
  end

  def edit
    @restaurants = Restaurant.all.order(:name)
  end

  def create
    @taco = Taco.new(taco_params)
    if @taco.save
      redirect_to @taco, notice: "Taco was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @taco.update(taco_params)
      redirect_to @taco, notice: "Taco was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @taco.destroy
    redirect_to tacos_url, notice: "Taco was successfully destroyed."
  end

  private
    def set_taco
      @taco = Taco.find(params[:id])
    end

    def taco_params
      params.require(:taco).permit(:restaurant_id, :name, :description, :price_cents, :calories, :tortilla_type, :protein_type, :is_vegan, :is_bulk, :is_daily_special, :available_from, :available_to)
    end
end
