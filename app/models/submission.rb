class Submission < ActiveRecord::Base
  belongs_to :applicant
  belongs_to :opening

  has_many :submission_answers, :order => 'group_order, question_order'
  accepts_nested_attributes_for :submission_answers

  has_many :applicant_files

  delegate :position, :department, :question_groups, :to => :opening
  delegate :first_name, :first_name=, :last_name, :last_name=,
           :preferred_name, :preferred_name=, :address_1, :address_1=,
           :address_2, :address_2=, :city, :city=, :state, :state=,
           :zip, :zip=, :country, :country=, :home_phone, :home_phone=,
           :cell_phone, :cell_phone=, :email, :email=, :to => :applicant

  after_create :copy_questions

  attr_protected :completed, :recruiter_recommendation, :hired, :began_hiring

  def copy_questions
    if self.opening
      self.opening.question_groups.each_with_index do |qg, i|
        qg.questions.each_with_index do |q, j|
          self.submission_answers.create(:question_id => q.id, :question_text => q.prompt, :question_type => q.question_type, :group_order => i + 1, :question_order => j + 1)
        end
      end
    end
  end
end
