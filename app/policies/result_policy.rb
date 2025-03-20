# frozen_string_literal: true

class ResultPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(experiment: :dataset).merge(ExperimentPolicy::Scope.new(user, Experiment).resolve)
    end
  end

  delegate :show?, to: :dataset_policy

  delegate :update?, to: :dataset_policy

  private def dataset_policy
    DatasetPolicy.new(user, record.experiment.dataset)
  end
end
