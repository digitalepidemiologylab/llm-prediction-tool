# frozen_string_literal: true

class Results::DataController < AuthenticatedBaseController
  before_action :set_result

  def show
    send_data(
      JSON.pretty_generate(@result.data),
      filename: "result_#{@result.id}.json",
      type: "application/json",
      disposition: "attachment"
    )
  end

  private def set_result
    @result = Result.find(params[:result_id])
    authorize(@result, :show?, policy_class: Results::DataPolicy)
  end
end
