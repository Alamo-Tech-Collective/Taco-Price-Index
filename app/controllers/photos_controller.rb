class PhotosController < ApplicationController
  before_action :require_authentication
  before_action :set_photo, only: %i[show edit update destroy]

  def index
    @photos = Photo.all
  end

  def show
  end

  def new
    @photo = Photo.new
  end

  def edit
  end

  def create
    @photo = Photo.new(photo_params)
    if @photo.save
      redirect_to @photo, notice: "Photo was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @photo.update(photo_params)
      redirect_to @photo, notice: "Photo was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @photo.destroy
    redirect_to photos_url, notice: "Photo was successfully destroyed."
  end

  private
    def set_photo
      @photo = Photo.find(params[:id])
    end

    def photo_params
      params.require(:photo).permit(:taco_id, :user_id, :url, :is_user_uploaded)
    end
end
