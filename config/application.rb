# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LlmBenchmark
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "UTC"

    config.middleware.use(Rack::Deflater)

    config.i18n.available_locales = %w[en]
    config.i18n.default_locale = "en"
    config.i18n.fallbacks = %w[en]

    config.exceptions_app = routes

    # In .env.override, from `rails secret`
    config.secret_key_base = ENV.fetch("SECRET_KEY_BASE")

    # In .env.override, from `rails db:encryption:init`
    config.active_record.encryption.primary_key = ENV.fetch("AR_ENC_PRIMARY_KEY")
    config.active_record.encryption.deterministic_key = ENV.fetch("AR_ENC_DETERMINISTIC_KEY")
    config.active_record.encryption.key_derivation_salt = ENV.fetch("AR_ENC_KEY_DERIVATION_SALT")

    config.active_job.queue_adapter = :solid_queue
    config.solid_queue.connects_to = {database: {writing: :queue}}

    config.mission_control.jobs.base_controller_class = "MissionControlJobsController"
    config.mission_control.jobs.http_basic_auth_enabled = false
    config.mission_control.jobs.show_console_help = false # Hide `jobs_help` hint

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
  end
end
