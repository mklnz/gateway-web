APP_DIR = File.expand_path("../..", __FILE__).freeze
TMP_DIR = "#{app_dir}/tmp".freeze

threads 1, 1

# Specifies the `port` that Puma will listen on to receive requests, default is 3000.
#
port        ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

pidfile "#{TMP_DIR}/pids/puma.pid"
state_path "#{TMP_DIR}/pids/puma.state"

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
