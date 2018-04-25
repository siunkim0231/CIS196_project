class StatusesController < ApplicationController
  before_action :set_status, only: [:edit, :update, :destroy]

  def new
    @status = Status.new
  end

  def edit
    redirect_to root_path unless @status.user == current_user
  end

  def create
    @status = current_user.statuses.new(status_params)

    if @status.save
      redirect_to @status.user
    else
      render :new
    end
  end

  def update
    if @status.user == current_user && @status.update(status_params)
      redirect_to @status.user
    else
      render :edit
    end
  end

  def destroy
    @status.destroy if @status.user == current_user
    redirect_back(fallback_location: @status.user)
  end

  private

  def set_status
    @status = Status.find(params[:id])
  end

  def status_params
    params.require(:status).permit(:text)
  end
end
