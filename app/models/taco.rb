class Taco < ApplicationRecord
  belongs_to :restaurant
  
  # Active Storage attachments
  has_many_attached :photos
  
  # Validations
  validates :name, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  # Scopes
  scope :with_photos, -> {
    joins("INNER JOIN active_storage_attachments " \
          "ON active_storage_attachments.record_id = tacos.id::text " \
          "AND active_storage_attachments.record_type = 'Taco'")
    .distinct
  }
  
  # Check if any photos are attached
  def has_photos?
    photos.attached?
  end
  
  # Returns the first photo variant for display
  def display_photo(variant = :medium)
    return unless photos.attached?
    
    begin
      photo = photos.first
      return photo unless photo.variable?
      
      case variant.to_sym
      when :thumb
        photo.variant(resize_to_limit: [200, 200]).processed
      when :medium
        photo.variant(resize_to_limit: [400, 300]).processed
      else
        photo
      end
    rescue => e
      Rails.logger.error "Error processing photo variant: #{e.message}"
      nil
    end
  end
  
  # Alias for has_photos? for better readability
  alias_method :photos_attached?, :has_photos?
  
  # Check if photos are attached (for use in views)
  def photos_attached?
    photos.attached?
  end
end
