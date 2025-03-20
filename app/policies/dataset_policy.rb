# frozen_string_literal: true

class DatasetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user:)
    end
  end

  def index?
    true
  end

  def show?
    update?
  end

  def create?
    user.present?
  end

  def update?
    record.user == user
  end
end
