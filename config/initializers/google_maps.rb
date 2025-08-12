# frozen_string_literal: true

# Load Google Maps API key from environment variables
Rails.application.config.after_initialize do
  # Check if the API key is set
  unless ENV["GOOGLE_MAPS_API_KEY"].present?
    warn "WARNING: GOOGLE_MAPS_API_KEY is not set in the environment variables."
    warn "Please add it to your .env file or set it in your environment."
  end

  # Make the API key available to the frontend
  GoogleMapsApi.api_key = ENV["GOOGLE_MAPS_API_KEY"] if defined?(GoogleMapsApi)
end
