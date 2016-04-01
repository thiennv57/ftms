class CreateCourseSubjects < ActiveRecord::Migration
  def change
    create_table :course_subjects do |t|
      t.integer :position, default: 0
      t.string :subject_name
      t.string :subject_avatar
      t.text :subject_description
      t.text :subject_content
      t.references :subject, index: true, foreign_key: true
      t.references :course, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
