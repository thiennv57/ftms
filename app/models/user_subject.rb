class UserSubject < ActiveRecord::Base
  include PublicActivity::Model

  has_many :activities, as: :trackable, class_name: "PublicActivity::Activity", dependent: :destroy

  belongs_to :user
  belongs_to :course
  belongs_to :user_course
  belongs_to :course_subject
  has_many :user_tasks, dependent: :destroy

  accepts_nested_attributes_for :user_tasks

  after_create :create_user_tasks

  scope :load_user_subject, ->(user_id, course_id){where "user_id = ? AND course_id = ?", user_id, course_id}
  scope :load_users, ->status {where status: status}
  scope :not_finish, -> user_subjects {where.not(id: user_subjects)}
  scope :sort_by_course_subject, ->{joins(:course_subject).order("course_subjects.order asc")}
  scope :count_user_tasks, -> status {joins(:user_tasks).where("user_tasks.status = ?", status).count}

  enum status: [:init, :progress, :finish]

  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :name, :description, to: :subject, prefix: true, allow_nil: true
  delegate :name, to: :course, prefix: true, allow_nil: true

  def load_trainers
    course.users.trainers
  end

  def load_trainees
    course.users.trainees
  end

  class << self
    def update_all_status status, current_user, course_subject
      if status == "start"
        load_users(statuses[:init]).update_all(status: statuses[:progress], start_date: Time.now)
        key = "user_subject.start_all_subject"
      else
        load_users(statuses[:progress]).update_all(status: statuses[:finish], end_date: Time.now)
        key = "user_subject.finish_all_subject"
      end
      course_subject.create_activity key: key, owner: current_user, recipient: course_subject.course
    end
  end

  def update_status current_user
    if init?
      update_attributes(status: :progress, start_date: Time.now)
      key = "user_subject.start_subject"
    else
      update_attributes(status: :finish, end_date: Time.now)
      key = "user_subject.finish_subject"
    end
    create_activity key: key, owner: current_user, recipient: user
  end

  def subject
    self.course_subject.subject
  end

  def name
    course_subject.subject.name
  end

  def description
    course_subject.subject.description
  end

  def content
    course_subject.subject.content
  end

  def image_url
    course_subject.image_url
  end

  def is_of_user? user
    self.user == user
  end

  private
  def create_user_tasks
    course_subject.tasks.each do |task|
      UserTask.find_or_create_by(user_subject_id: id,
        user_id: user_course.user_id, task_id: task.id)
    end
  end
end
