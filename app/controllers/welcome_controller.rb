class WelcomeController < ApplicationController
  def index
    @status = Status.new
    return unless logged_in?
    @statuses = Status.where(user: current_user.friends).or(Status.where(user: current_user))
  end
end
