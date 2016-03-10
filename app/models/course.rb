class Course < ActiveRecord::Base
  include PublicActivity::Model
  include InitUserSubject
  tracked only: [:finish_course, :start_course],
    owner: ->(controller, model) {controller.current_user}
  has_many :activities, as: :trackable, class_name: "PublicActivity::Activity", dependent: :destroy

  validate :check_day_present, on: [:create, :update]
  validate :check_end_date, on: [:create, :update]

  validates :start_date, presence: true unless :master?
  validates :end_date, presence: true unless :master?
  validates :name, uniqueness: true

  has_many :childrens, class_name: Course.name, foreign_key: :parent_id
  belongs_to :parent, class_name: Course.name

  has_many :course_subjects, dependent: :destroy
  has_many :user_courses, dependent: :destroy
  has_many :user_subjects, dependent: :destroy
  has_many :users, through: :user_courses
  has_many :subjects, through: :course_subjects

  has_many :course_leaders, class_name: UserCourse.name,
                            dependent: :destroy,
                            foreign_key: :course_id,
                            inverse_of: :course
  has_many :leaders, through: :course_leaders

  has_many :course_supervisors, class_name: UserCourse.name,
                                dependent: :destroy,
                                foreign_key: :course_id,
                                inverse_of: :course
  has_many :supervisors, through: :course_supervisors

  enum status: [:init, :progress, :finish]

  scope :recent, ->{order created_at: :desc}

  scope :active_course, ->{where status: "progress"}

  scope :masters,->{where parent_id: nil}
  scope :normal,->{where.not parent_id: nil}

  def create_user_subjects_when_start_course
    create_user_subjects user_courses, course_subjects, id, false
  end

  def create_course_owner user
    UserCourse.create user_id: user.id, course_id: id
  end

  def check_day_present
    unless self.start_date.nil?
      self.errors.add :start_date, I18n.t("error.wrong_date") if
        self.start_date.to_date < Date.today
    end
  end

  def check_end_date
    unless self.start_date.nil?
      errors.add :end_date, I18n.t("error.wrong_end_date") if
        self.end_date < self.start_date
    end
  end

  def start_course
    self.update_attributes status: :progress
    create_user_subjects_when_start_course
  end

  def finish_course
    self.update_attributes status: :finish
  end

  private
  def master?
    parent_id.nil?
  end
end
