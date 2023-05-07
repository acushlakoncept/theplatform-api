require_relative "../config/initializers/hash"
require 'pp'
begin
  require 'dotenv'
rescue LoadError
end

app_cfg =
    {
        :app_name => "ThePlatform: API",
    }

# Look for an application.yml file in the config directory.
app_cfg_path = File.join(Rails.root, "config", "application.yml")

if File.exists?(app_cfg_path)
  # puts "Reading settings from #{app_cfg_path} for the #{Rails.env} environment."
  if Rails.env.test?
    Dotenv.load('.env.sample')
  end

  # If it exists and it has a key for the current environment, merge into/over above settings.

  # Load application.yml as an ERB template to allow reading of ENV variables.
  template = ERB.new(File.new(app_cfg_path).read)

  # Load file and run through ERB template reader before loading as YAML.
  user_settings = HashWithIndifferentAccess.new(YAML.load(template.result(binding)))[Rails.env]

  if !%q[production staging].include?(Rails.env)
    # pp(user_settings)
  end

  app_cfg.merge!(user_settings)
else
  puts "No settings for #{Rails.env} environment."
end

# No fooling around with the config once it's loaded.
if Rails.env.test?
  # we can't freeze in test environment, as we often need to run tests with multiple config
  APP_CONFIG = app_cfg.to_ostruct
else
  APP_CONFIG = app_cfg.to_ostruct.freeze
end
