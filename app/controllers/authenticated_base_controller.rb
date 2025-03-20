# frozen_string_literal: true

class AuthenticatedBaseController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized
  after_action :verify_policy_scoped, if: -> { action_name == "index" }
end
