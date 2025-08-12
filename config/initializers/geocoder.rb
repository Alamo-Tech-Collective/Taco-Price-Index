Geocoder.configure(
  # Geocoding service configuration
  lookup: :google,
  api_key: ENV["GOOGLE_MAPS_API_KEY"],

  # Geocoding service timeout (in seconds)
  timeout: 5,

  # Default units
  units: :mi,

  # Cache configuration
  cache: Rails.cache,
  cache_options: {
    expiration: 1.day,
    prefix: "geocoder:"
  }
)
