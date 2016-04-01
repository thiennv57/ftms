class Task < ActiveRecord::Base
  belongs_to :course_subject
  has_many :user_tasks, dependent: :destroy
  belongs_to :assigned_trainee, class_name: User.name
  mount_uploader :avatar, AvatarUploader

  ATTRIBUTES_PARAMS = [
    :name, :description, :assigned_trainee_id, :course_subject_id, :trainee_task
  ]

  scope :not_assigned_trainee, -> do
    where assigned_trainee_id: nil, task_master_id: nil, trainee_task: true
  end

  after_save :change_user_task

  def assign_trainees_to_task
    if task_of_trainer?
      user_subjects = self.course_subject.user_subjects
      user_subjects.each do |user_subject|
        UserTask.create(task_id: self.id, user_subject_id: user_subject.id)
      end
    end
  end

  def task_of_trainer?
    trainee_task == false
  end

  private
  def change_user_task
    return if assigned_trainee.nil?
    user_task = user_task_of_trainee
    if user_task.nil?
      self.user_tasks.create user: assigned_trainee,
        user_subject: user_subject
    else
      user_task.update_attributes user: assigned_trainee,
        user_subject: user_subject
    end
  end

  def user_task_of_trainee
    UserTask.find_by user: self.changed_attributes["assigned_trainee_id"],
      task: self
  end

  def user_subject
    self.course_subject.user_subjects.find_by user: assigned_trainee
  end
end
