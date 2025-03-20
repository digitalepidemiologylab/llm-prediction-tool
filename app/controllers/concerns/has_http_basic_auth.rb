# frozen_string_literal: true

module HasHttpBasicAuth
  extend ActiveSupport::Concern

  included do
    before_action :http_basic_auth, if: -> { Rails.env.production? }
  end

  private def http_basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username_ok = secure_compare(username, ENV.fetch("BASIC_AUTH_USERNAME"))
      password_ok = secure_compare(password, ENV.fetch("BASIC_AUTH_PASSWORD"))
      username_ok && password_ok
    end
  end

  private def secure_compare(a, b)
    hashed_a = Digest::SHA256.hexdigest(a)
    hashed_b = Digest::SHA256.hexdigest(b)
    ActiveSupport::SecurityUtils.secure_compare(hashed_a, hashed_b)
  end
end
