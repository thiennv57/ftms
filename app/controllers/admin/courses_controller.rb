class Admin::CoursesController < ApplicationController
  load_and_authorize_resource
  before_action :load_subjects, only: [:new, :create, :edit]

  def index
    @courses = @courses.normal.recent
  end

  def new
    @parent_id = params[:parent_id]
    @parent_name = params[:parent_name]
    @parent_description = params[:parent_description]
  end

  def create
    @course = Course.new course_params
    if @course.save
      @course.create_course_owner current_user
      flash[:success] = flash_message "created"
      redirect_to admin_courses_path
    else
      flash[:failed] = flash_message "not created"
      render :new
    end
  end

  def update
    if @course.update_attributes course_params
      flash[:success] = flash_message "updated"
      redirect_to admin_courses_path
    else
      flash[:failed] = flash_message "not updated"
      render :edit
    end
  end

  def show
    @course_subjects = @course.course_subjects
  end

  def destroy
    if @course.destroy
      flash[:success] = flash_message "deleted"
    else
      flash[:failed] = flash_message "not deleted"
    end
    redirect_to :back
  end

  private
  def course_params
    params.require(:course).permit :name, :description, :start_date,
      :end_date, :parent_id, subject_ids: []
  end

  def load_subjects
    @subjects = Subject.all
  end
end
