class Restaurant < ApplicationRecord
  # Associations
  has_many :tacos, dependent: :destroy
  has_many :photos, through: :tacos
  has_many :reviews, dependent: :destroy

  has_many :user_favorites, dependent: :destroy
  has_many :favorited_by, through: :user_favorites, source: :user

  # Geocoding
  geocoded_by :full_address
  after_validation :geocode, if: ->(obj) {
    obj.full_address.present? &&
    (obj.latitude.blank? || obj.longitude.blank?) &&
    (obj.street_address_changed? || obj.city_changed? || obj.state_changed? || obj.zip_changed?)
  }

  # Store business hours as JSON in a text field
  serialize :business_hours, coder: JSON

  # Validations
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true

  # Virtual attribute for simple hours display
  attr_accessor :hours

  # Days of the week for hours display
  DAYS = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

  def favorite_for?(user)
    user_favorites.exists?(user: user)
  end

  # Returns the number of users who have favorited this restaurant
  # Uses counter_cache for better performance
  def favorite_count
    # If using counter_cache, this will be fast
    respond_to?(:user_favorites_count) ? user_favorites_count : user_favorites.count
  end

  # Returns a formatted string of business hours
  def hours
    return @hours if @hours.present?
    return unless business_hours.present?

    # If we have business_hours as JSON, format them
    if business_hours.is_a?(Hash)
      business_hours.map do |day, hours|
        "#{day}: #{hours}"
      end.join("<br>").html_safe
    else
      # Fallback to simple hours if set
      business_hours
    end
  end

  # Returns hours for a specific day of the week (0-6, where 0 is Sunday)
  def hours_for_day(day_index)
    return unless business_hours.is_a?(Hash)
    day_name = DAYS[day_index % 7]
    business_hours[day_name] || "Closed"
  end

  # Returns the full address for geocoding
  def full_address
    [ street_address, city, state, zip ].compact.join(", ")
  end

  # Returns true if the restaurant is currently open
  def open_now?
    return false unless business_hours.is_a?(Hash)

    now = Time.current
    day_name = DAYS[now.wday]
    hours_today = business_hours[day_name]

    return false unless hours_today.present? && hours_today != "Closed"

    # Simple check - in a real app, you'd want to parse the hours
    # and compare with current time
    true
  end

  # Returns a status string (Open/Closed) based on current time
  def status
    open_now? ? "Open Now" : "Closed Now"
  end
end
