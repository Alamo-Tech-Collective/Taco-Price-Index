class Review < ApplicationRecord
  belongs_to :restaurant
  belongs_to :user, optional: true  # Optional because of Google reviews without users
  has_many_attached :photos

  # For Google reviews
  validates :google_rating, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5,
    allow_nil: true
  }

  # For app reviews
  validates :fullness_rating, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5,
    allow_nil: true
  }

  # For Google reviews that might not have a user
  def author
    if user.present?
      if user.respond_to?(:username) && user.username.present?
        user.username
      elsif user.respond_to?(:name) && user.name.present?
        user.name
      elsif user.respond_to?(:email_address) && user.email_address.present?
        user.email_address
      elsif user.respond_to?(:email) && user.email.present?
        user.email
      else
        "Anonymous"
      end
    elsif author_name.present?
      author_name
    else
      "Anonymous"
    end
  end

  def rating
    google_rating || fullness_rating
  end

  def submitted_at_display
    submitted_at || review_date || created_at
  end

  def content_display
    content.presence || review_text.presence || "No review text available."
  end

  def google_review?
    google_rating.present?
  end

  def app_review?
    fullness_rating.present? || content.present?
  end
end
