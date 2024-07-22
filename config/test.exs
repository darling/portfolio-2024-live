import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :meowmeow, MeowmeowWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "66t+7GphWrG1BQXBGOy1VKdkQ459SagWjh6bEeY2rdITPyMqNqZqpxCA2rXvEy5o",
  server: false

# In test we don't send emails.
config :meowmeow, Meowmeow.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true
