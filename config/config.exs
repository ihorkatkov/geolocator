# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :geolocator,
  ecto_repos: [Geolocator.Repo],
  csv_stream_chunk_size: 1000

# Set migrations timestamp type to :naive_datetime_usec (timestamp with milliseconds)
config :geolocator, Geolocator.Repo, migration_timestamps: [type: :naive_datetime_usec]

# Configures the endpoint
config :geolocator, GeolocatorWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: GeolocatorWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Geolocator.PubSub,
  live_view: [signing_salt: "w+gn9gDy"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
