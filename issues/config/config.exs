use Mix.Config

# import config depending on environment, either: dev.exs, test.exs or prod.exs
# import_config "#{Mix.env}.exs"

config :issues,
  github_url: "https://api.github.com"

config :logger,
  compile_time_purge_level: :info
