# frozen_string_literal: true

module HasPunditAuth
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization

    def pundit_user
      current_user || User.new
    end
  end
end
