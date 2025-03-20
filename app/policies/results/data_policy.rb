# frozen_string_literal: true

module Results
  class DataPolicy < ApplicationPolicy
    def show?
      dataset_policy.show? && record.final? && data_available?
    end

    private def dataset_policy
      DatasetPolicy.new(user, record.experiment.dataset)
    end

    private def data_available?
      record.data["annotations"].present?
    end
  end
end
