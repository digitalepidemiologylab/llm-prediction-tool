# frozen_string_literal: true

Rails.application.config.solid_cache.expires_in = 1.day
Rails.application.config.solid_cache.race_condition_ttl = 10.seconds
