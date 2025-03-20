# frozen_string_literal: true

class Results::CancellationsController < AuthenticatedBaseController
  before_action :set_result

  def create
    service = Results::CancelService.new(result: @result)
    if service.call
      flash[:notice] = t(".flash_success")
    else
      flash[:alert] = t(".flash_error")
    end
    redirect_to experiment_path(@result.experiment)
  end

  private def set_result
    @result = Result.find(params[:result_id])
    authorize(@result, :edit?)
  end
end
