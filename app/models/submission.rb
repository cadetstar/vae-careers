class Submission < ActiveRecord::Base
  belongs_to :applicant
  belongs_to :opening

  has_many :submission_answers, :order => 'group_order, question_order'
  has_many :applicant_files
  accepts_nested_attributes_for :submission_answers
  accepts_nested_attributes_for :applicant_files

  has_many :comments, :as => :owner


  delegate :position, :department, :question_groups, :to => :opening
  delegate :first_name, :first_name=, :last_name, :last_name=,
           :preferred_name, :preferred_name=, :address_1, :address_1=,
           :address_2, :address_2=, :city, :city=, :state, :state=,
           :zip, :zip=, :country, :country=, :home_phone, :home_phone=,
           :cell_phone, :cell_phone=, :email, :email=, :city_state, :to => :applicant

  before_save  :bounce_new_record
  after_create :copy_questions
  after_save   :check_for_completion

  after_update do |s|
    s.applicant.save if s.applicant.changed?
  end

  serialize :incomplete_notices

  attr_protected :completed, :recruiter_recommendation, :hired, :began_hiring

  def bounce_new_record
    @perform_completion_check = !new_record?
  end

  def copy_questions
    if self.opening
      self.opening.question_groups.each_with_index do |qg, i|
        qg.questions.each_with_index do |q, j|
          self.submission_answers.create(:question_id => q.id, :question_text => q.prompt, :question_type => q.question_type, :group_order => i + 1, :question_order => j + 1)
        end
      end
    end
  end

  def check_for_completion
    self.incomplete_notices = []
    unless @perform_completion_check
      return true
    end
    [:first_name, :last_name, :email].each do |f|
      if self.send(f).blank?
        self.incomplete_notices << "You must give your #{f.to_s.humanize.downcase}."
      end
    end

    self.incomplete_notices << "You must agree to the privacy affidavit" unless self.affidavit

    self.submission_answers.includes(:question).each do |sa|
      if sa.question.required
        if sa.answer.blank?
          self.incomplete_notices << "You must answer the question '#{sa.question_text}'"
        end
      end
    end
    if self.incomplete_notices.blank? and !self.completed
      self.completed = true
      self.save
      self.after_completion
    end
    true
  end

  def after_completion

  end

  def self.indexed_attributes
    [:first_name, :last_name, ]
  end
end
