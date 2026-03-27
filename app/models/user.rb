class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :user_favorites, dependent: :destroy
  has_many :favorite_restaurants, through: :user_favorites, source: :restaurant
  has_one_attached :avatar

  # Default scope for active users
  scope :admin, -> { where(admin: true) }

  # Rails login
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.blank? }

  def favorite?(restaurant)
    return false if restaurant.nil?
    favorite_restaurants.exists?(restaurant.id)
  end

  def toggle_favorite(restaurant)
    if favorite?(restaurant)
      user_favorites.find_by(restaurant: restaurant).destroy
    else
      user_favorites.create(restaurant: restaurant)
    end
  end

  def admin?
    admin == true
  end

  def name
    username.presence || email_address.split("@").first
  end
end
