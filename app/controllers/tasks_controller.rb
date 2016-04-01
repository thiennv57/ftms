class TasksController < ApplicationController
  load_and_authorize_resource

  def create
    if @task.save
      flash[:success] = flash_message "created"
      @task.assign_trainees_to_task
    else
      flash[:failed] = flash_message "not created"
    end
    redirect_to :back
  end

  def update
    if @task.update_attributes task_params
      flash[:success] = flash_message "updated"
    else
      flash[:failed] = flash_message "not_updated"
    end
    redirect_to :back
  end

  private
  def task_params
    params.require(:task).permit Task::ATTRIBUTES_PARAMS
  end
end
