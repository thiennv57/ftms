class Admin::SubjectsController < ApplicationController
  load_and_authorize_resource
  before_action :init_subject, only: [:show]

  def index
    @subject = Subject.new
    @subjects = Subject.all.recent
  end

  def show
    @task_masters = @subject.task_masters
  end

  def create
    @subject = Subject.new subject_params
    if @subject.save
      flash[:success] = flash_message "created"
      redirect_to admin_subjects_path
    else
      flash[:failed] = flash_message "not created"
      render :new
    end
  end

  def edit
  end

  def update
    if @subject.update_attributes subject_params
      flash[:success] = flash_message "updated"
      redirect_to admin_subjects_path
    else
      flash[:failed] = flash_message "not updated"
      render :edit
    end
  end

  def destroy
    if @subject.destroy
      flash[:success] = flash_message "deleted"
    else
      flash.now[:failed] = flash_message "not deleted"
    end
    respond_to do |format|
      format.html {redirect_to admin_subjects_path}
      format.js
    end
  end

  private
  def subject_params
    params.require(:subject).permit :name, :description,
      task_masters_attributes: [:id, :name, :description, :_destroy]
  end

  def init_subject
    @subject = Subject.find params[:id]
  end
end
