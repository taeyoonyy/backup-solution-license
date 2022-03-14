import Config

config :backsol, Backsol.Repo,
  database: "backsol_repo",
  username: "postgres",
  password: "admin",
  hostname: "localhost"

config :backsol, ecto_repos: [Backsol.Repo]
