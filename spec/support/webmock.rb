# frozen_string_literal: true

require "webmock/rspec"

RSpec.configure do |config|
  config.before do
    # No network activity allowed but we still allow download
    # of updated chromedriver if needed (useful for system tests in docker)
    WebMock.disable_net_connect!(
      allow_localhost: true,
      allow: [
        "chromedriver.storage.googleapis.com",
        ENV["SELENIUM_REMOTE_HOST"]
      ].compact
    )
  end
end
