require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TacoPriceIndex
  class Application < Rails::Application
    # Load environment variables from .env file
    config.before_configuration do
      env_file = File.join(Rails.root, ".env")
      if File.exist?(env_file)
        File.foreach(env_file) do |line|
          key, value = line.strip.split("=", 2)
          ENV[key] = value if key.present? && value.present?
        end
      end
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Central Time (US & Canada)"
    config.eager_load_paths << Rails.root.join("extras")

    # Add StimulusReflex configuration
    config.stimulus_reflex = {
      cable_url: "ws://localhost:3000/cable",
      reflex_class: "ApplicationReflex"
    }
  end
end
