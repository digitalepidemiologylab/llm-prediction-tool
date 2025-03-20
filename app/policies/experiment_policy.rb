# frozen_string_literal: true

class ExperimentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:dataset).merge(DatasetPolicy::Scope.new(user, Dataset).resolve)
    end
  end

  def show?
    update?
  end

  def create?
    update?
  end

  delegate :update?, to: :dataset_policy

  private def dataset_policy
    DatasetPolicy.new(user, record.dataset)
  end
end
