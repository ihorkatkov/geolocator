import Config

# Do not print debug messages in production
config :logger, level: :info

config :geolocator,
  # Fly.io instance is too small to handle 1000
  csv_stream_chunk_size: 100

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
