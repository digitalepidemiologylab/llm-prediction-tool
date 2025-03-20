# frozen_string_literal: true

class DatasetsController < AuthenticatedBaseController
  before_action :set_and_authorize_new_dataset, only: %i[new create]

  def index
    authorize(Dataset)
    @datasets = policy_scope(Dataset).order(:created_at)
  end

  def show
    @dataset = Dataset.find(params[:id])
    authorize(@dataset)
    @experiments = policy_scope(@dataset.experiments).order(:created_at)
  end

  def new
  end

  def create
    if @dataset.update(dataset_params)
      redirect_to dataset_path(@dataset), notice: t(".flash_success")
    else
      flash.now[:alert] = t(".flash_failure")
      render :new, status: :unprocessable_entity
    end
  end

  private def dataset_params
    params.expect(dataset: [:name, :evaluation, :column_separator])
  end

  private def set_and_authorize_new_dataset
    @dataset = Dataset.new(user: current_user)
    authorize(@dataset)
  end
end
