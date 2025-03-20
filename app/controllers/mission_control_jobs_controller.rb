# frozen_string_literal: true

class MissionControlJobsController < ApplicationController
  before_action :authorize_mcj_actions!

  private def authorize_mcj_actions!
    authorize(:mission_control_jobs, :index?)
  end
end
