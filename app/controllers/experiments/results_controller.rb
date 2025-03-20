# frozen_string_literal: true

class Experiments::ResultsController < AuthenticatedBaseController
  before_action :set_and_authorize_experiment

  def create
    @result = @experiment.results.new

    if @result.save
      Results::ProcessRowJob.perform_later(result: @result, index: 0)
      redirect_to experiment_path(@experiment), notice: t(".flash_success")
    else
      redirect_to experiment_path(@experiment), alert: t(".flash_failure")
    end
  end

  private def set_and_authorize_experiment
    @experiment = Experiment.find(params[:experiment_id])
    authorize(@experiment, :update?)
  end
end
