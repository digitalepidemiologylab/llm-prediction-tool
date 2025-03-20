# frozen_string_literal: true

class MissionControlJobsPolicy < ApplicationPolicy
  def index?
    user.admin?
  end
end
