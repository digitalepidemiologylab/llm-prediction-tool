# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.4.2"

gem "rails", "~> 8.0.2"

# DB
gem "pg"
gem "strong_migrations"

# State machine
gem "aasm"

# Authentication
gem "devise"
gem "devise-i18n"

# Authorization
gem "pundit"

# Server
gem "puma"
gem "thruster", require: false

# Solid Cache/Cable
gem "solid_cache"
gem "solid_cable"

# Frontend
gem "importmap-rails"
gem "propshaft"
gem "stimulus-rails"
gem "turbo-rails"

# Background jobs
gem "solid_queue"
gem "mission_control-jobs"

# Error reporting
gem "sentry-rails"
gem "sentry-ruby"

# Misc
gem "aws-sdk-s3"
gem "bootsnap", require: false
gem "httparty"
gem "rubyzip"

group :development, :test do
  gem "better_html"
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "erb_lint", require: false
  gem "factory_bot_rails"
  gem "faker"
  gem "i18n-tasks"
  gem "parallel_tests"
  gem "rspec-rails"
  gem "rubocop-rails_config", require: false
  gem "rubocop-rspec", require: false
  gem "standard"
end

group :development do
  gem "brakeman"
  gem "web-console"
  gem "letter_opener_web"
end

group :test do
  gem "capybara"
  gem "simplecov", require: false
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "webmock"
end
