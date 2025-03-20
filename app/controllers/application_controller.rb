# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include HasHttpBasicAuth
  include HasPunditAuth

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
