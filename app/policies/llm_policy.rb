# frozen_string_literal: true

class LlmPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(deployed_by_user: [nil, user])
    end
  end
end
