# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Database Management
```bash
# Start PostgreSQL database (Docker)
bin/db up

# Stop PostgreSQL database  
bin/db down

# Run database migrations
bin/rails db:migrate

# Seed database with sample data
bin/rails db:seed

# Access Rails console
bin/rails console
```

### Development Server
```bash
# Start Rails server
bin/rails server

# Build CSS assets
npm run build:css
# OR
yarn build:css
```

### Testing
```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/models/restaurant_test.rb

# Run specific test
bin/rails test test/models/restaurant_test.rb:15
```

### Code Quality
```bash
# Run Rubocop linter
bin/rubocop

# Run Brakeman security analysis
bin/brakeman
```

### Background Jobs
```bash
# Start background job processor
bin/jobs
```

## Architecture Overview

### Application Structure
This is a Rails 8.0.2 application for tracking taco prices in San Antonio, Texas. It uses:
- **Database**: PostgreSQL (via Docker in development, pg gem in production)
- **Frontend**: Hotwire (Turbo + Stimulus), Bootstrap 5.3, Font Awesome
- **Maps Integration**: Google Maps JavaScript API
- **Authentication**: Custom authentication using bcrypt (not Devise despite gem presence)
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **Real-time Updates**: Solid Cable + Stimulus Reflex

### Core Models & Relationships
```ruby
Restaurant
  has_many :tacos
  has_many :photos (through tacos)
  has_many :reviews
  has_many :user_favorites
  has_many :favorited_by (users through user_favorites)

Taco
  belongs_to :restaurant
  has_many :photos

Review
  belongs_to :restaurant
  belongs_to :user (optional)

User
  has_many :sessions
  has_many :user_favorites
  has_many :favorite_restaurants (through user_favorites)
```

### Key Features
1. **Restaurant Management**: Full CRUD with geocoding via latitude/longitude
2. **Favorites System**: Users can favorite restaurants, tracked via UserFavorite join table
3. **Review System**: Supports both Google Places reviews and user-submitted reviews
4. **Photo Management**: Uses Active Storage for user uploads
5. **Map Integration**: Restaurant locations displayed on interactive Google Maps
6. **Business Hours**: Stored as JSON in restaurant model
7. **Delivery/Pickup Integration**: Stubbed methods for DoorDash/Favor/Maps integration

### Authentication Flow
- Custom authentication using sessions controller and bcrypt
- Current user stored in `Current.user` (CurrentAttributes)
- Authentication required via `before_action :require_authentication` in controllers
- Test login: test@example.com / password

### Frontend Pages
All frontend pages accessible at `/frontend_pages/*`:
- `/frontend_pages/map` - Interactive map view
- `/frontend_pages/restaurant_details` - Restaurant detail page
- `/frontend_pages/restaurant_review_form` - Review submission
- `/frontend_pages/user_profile` - User profile management
- `/frontend_pages/featured_spotlight` - Featured restaurants
- `/frontend_pages/restaurant_leaderboard` - Restaurant rankings
- `/frontend_pages/catering_bulk_order` - Bulk ordering interface

### Important Patterns
1. **Geocoding**: Only triggers when latitude/longitude missing to avoid unnecessary API calls
2. **Counter Caching**: `user_favorites_count` on restaurants for performance
3. **UUID Support**: User IDs can be UUIDs, handled specially in reviews
4. **Serialization**: Business hours stored as JSON using Rails serialization
5. **View Helpers**: ApplicationHelper contains shared view logic

### Data Collection
Python scripts in `/data_collection/` directory:
- `bc_tacos.py` - Scrapes Google Places API for taco data
- `export_to_rails_seeds.py` - Converts scraped data to Rails seeds
- Pre-seeded with 153 restaurants, 54 tacos, 540 photos, 765 reviews

### Environment Configuration
Required environment variables (set in `.env`):
- `GOOGLE_MAPS_API_KEY` - For map display in Rails views
- `POSTGRES_DB` - Database name (default: tacos_db)
- `POSTGRES_USER` - Database user (default: tacos)
- `POSTGRES_PASSWORD` - Database password

### Development Tips
1. Database runs in Docker - use `bin/db up` before starting Rails
2. Don't run `db:create` - Docker handles database creation
3. Use `bin/rails console` to explore data and test models
4. Frontend controllers inherit from ApplicationController with authentication
5. Check `app/javascript/controllers/` for Stimulus controllers handling interactivity