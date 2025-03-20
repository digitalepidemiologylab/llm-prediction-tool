# frozen_string_literal: true

module Datasets
  class ExperimentsController < AuthenticatedBaseController
    before_action :set_and_authorize_dataset
    before_action :set_new_experiment, only: %i[new create]
    before_action :set_available_grouped_llms, only: :new

    def new
    end

    def create
      if @experiment.update(experiment_params)
        redirect_to dataset_path(@dataset), notice: t(".flash_success")
      else
        flash.now[:alert] = t(".flash_failure")
        set_available_grouped_llms
        render :new, status: :unprocessable_entity
      end
    end

    private def experiment_params
      params.expect(experiment: [:llm_id, :system_prompt])
    end

    private def set_and_authorize_dataset
      @dataset = Dataset.find(params[:dataset_id])
      authorize(@dataset, :update?)
    end

    private def set_new_experiment
      @experiment = @dataset.experiments.new
    end

    private def set_available_grouped_llms
      allowed_llms = policy_scope(Llm).where(deprecated_at: nil).order(:provider, :name)
      @available_grouped_llms = allowed_llms.group_by(&:provider)
    end
  end
end
