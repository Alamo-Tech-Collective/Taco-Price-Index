class TestController < ApplicationController
  skip_before_action :require_authentication, only: [ :map_test ]

  def map_test
    @markers = [
      {
        id: "test-marker-1",
        lat: 29.4430149,
        lng: -98.5250144,
        name: "El Noa Noa Mexican Cafe",
        address: "1502 N Zarzamora St, San Antonio, TX, 78207",
        url: "#",
        favorite_count: 2,
        is_favorite: false,
        rating: 4.3,
        phone: "(210) 225-7201",
        website: "https://www.elnoanoasa.com/",
        hours: [
          "Monday: 7:00 AM – 9:00 PM",
          "Tuesday: 7:00 AM – 9:00 PM",
          "Wednesday: 7:00 AM – 9:00 PM",
          "Thursday: 7:00 AM – 9:00 PM",
          "Friday: 7:00 AM – 10:00 PM",
          "Saturday: 7:00 AM – 10:00 PM",
          "Sunday: 7:00 AM – 9:00 PM"
        ],
        price_level: 1,
        types: [ "restaurant", "food", "point_of_interest", "establishment" ]
      },
      {
        id: "test-marker-2",
        lat: 29.4435,
        lng: -98.5255,
        name: "Test Location 2",
        address: "1600 N Zarzamora St, San Antonio, TX, 78207",
        rating: 4.0
      },
      {
        id: "test-marker-3",
        lat: 29.4425,
        lng: -98.5245,
        name: "Test Location 3",
        address: "1400 N Zarzamora St, San Antonio, TX, 78207",
        rating: 4.5
      }
    ]

    # Set map center to the first marker's position
    @map_center = {
      lat: @markers.first[:lat],
      lng: @markers.first[:lng]
    }

    # Log the data being sent to the view
    Rails.logger.info "Sending map data:"
    Rails.logger.info "Center: #{@map_center.inspect}"
    Rails.logger.info "Markers: #{@markers.inspect}"
    Rails.logger.info "API Key Present: #{ENV['GOOGLE_MAPS_API_KEY'].present?}"
  end
end
