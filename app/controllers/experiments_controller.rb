# frozen_string_literal: true

class ExperimentsController < AuthenticatedBaseController
  def show
    @experiment = Experiment.find(params[:id])
    authorize(@experiment)
    @results = @experiment.results.order(:created_at)
  end
end
