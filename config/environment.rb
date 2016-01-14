ENV['DAEMON_ENV'] ||= 'development'

# Boot up
require File.join(File.dirname(__FILE__), 'boot')

# Auto-require default libraries and those for the current ruby environment
Bundler.require(:default, DaemonKit.env)
require 'active_support/inflector'
require 'yaml'

require 'config'

# Load the parameters
p = YAML.load_file(File.join(File.dirname(__FILE__), '/parameters.yml'))[DaemonKit.env]

# Check mandatory tokens
raise(ArgumentError, "RecastAI token is mandatory") if p['recast_key'] == nil
raise(ArgumentError, "Slack token is mandatory")    if p['slack_key'] == nil

# Configure Visjar
Visjar::Config.configure do |config|
  config.google_key = p['google_key']
  config.google_cx  = p['google_cx']
  config.recast_key = p['recast_key']
  config.location   = p['location']
  config.limit_eat  = p['limit_eat']
  config.limit_news = p['limit_news']
end

# Configure Slack
Slack.configure do |config|
  config.token = p['slack_key']
end

# Configure ForecastIO
ForecastIO.configure do |config|
  config.api_key = p['forecast_key']
end

# Configure DaemonKit
DaemonKit::Initializer.run do |config|
  config.daemon_name = 'visjar'
  config.backtraces  = true
  config.pid_file    = "./tmp/pids/#{config.daemon_name}.pid"
end

require 'utils'
require 'log'
require 'visjar'
require 'commands'
require 'commands/greetings'
require 'commands/goodbyes'
require 'commands/feelings'
require 'commands/thanks'
require 'commands/help'
require 'commands/weather'
require 'commands/search'
require 'commands/news'
require 'commands/eat'
