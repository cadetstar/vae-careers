require 'fileutils'
require 'zip/zip'
class Submission < ActiveRecord::Base
  belongs_to :applicant
  belongs_to :opening

  has_many :submission_answers, :order => 'group_order, question_order', :dependent => :destroy
  has_many :applicant_files, :dependent => :destroy
  has_one  :demographic
  accepts_nested_attributes_for :submission_answers
  accepts_nested_attributes_for :applicant_files
  accepts_nested_attributes_for :demographic

  has_many :comments, :as => :owner, :dependent => :destroy
  has_many :tags, :as => :owner, :dependent => :destroy
  has_many :tag_types, :through => :tags

  has_many :submission_users, :dependent => :destroy
  has_many :remote_users, :through => :submission_users

  delegate :position, :department, :question_groups, :to => :opening
  delegate :first_name, :first_name=, :last_name, :last_name=,
           :preferred_name, :preferred_name=, :address_1, :address_1=,
           :address_2, :address_2=, :city, :city=, :state, :state=,
           :zip, :zip=, :country, :country=, :home_phone, :home_phone=,
           :cell_phone, :cell_phone=, :email, :email=, :city_state,
           :home_or_cell, :combined_address, :full_address, :csz, :to => :applicant

  before_save  :bounce_new_record
  #after_create :copy_and_check_questions
  after_save   :check_for_completion

  after_update do |s|
    s.applicant.save if s.applicant.changed?
  end

  serialize :incomplete_notices

  attr_protected :completed, :recruiter_recommendation, :hired, :began_hiring

  REPORT_FIELD_OVERRIDES = {
      "id" => false,
      'tag_types' => true,
      'comments' => true,
      'first_name' => true,
      'last_name' => true,
      'preferred_name' => true,
      'address_1' => true,
      'address_2' => true,
      'city' => true,
      'state' => true,
      'zip' => true,
      'country' => true,
      'home_phone' => true,
      'cell_phone' => true,
      'email' => true,
      'city_state' => true
  }

  OVERRIDE_METHOD = {

  }

  scope :reports, joins(:applicant, :openings, :submission_answers, :demographic)

  def bounce_new_record
    @perform_completion_check = !new_record?
    true
  end

  def copy_and_check_questions
    current_answers = self.submission_answers.all
    if self.opening
      self.opening.question_groups.each_with_index do |qg, i|
        qg.questions.each_with_index do |q, j|
          assembly = {:question_id => q.id, :question_text => q.prompt, :question_type => q.question_type, :group_order => i + 1, :question_order => j + 1}
          if (csa = self.submission_answers.find_by_group_order_and_question_order(i + 1, j + 1))
            csa.update_attributes(assembly)
            current_answers -= [csa]
          else
            self.submission_answers.create(assembly)
          end
        end
      end
    end
    current_answers.each do |ca|
      ca.destroy
    end
    true
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
      if sa.question.try(:required)
        if sa.answer.blank?
          self.incomplete_notices << "You must answer the question '#{sa.question_text}'"
        end
      end
    end
    if self.incomplete_notices.empty? and !self.completed
      self.completed = true
      self.completed_at = Time.now
      self.save
      self.after_completion unless ENV['RAKING']
    end
    true
  end

  def after_completion
    # Send confirmation to applicant
    GeneralMailer.application_confirmation(self).deliver
    # Send notice to recruiter
    if (ru = RemoteUser.find_by_email(I18n.t('admins.primary.email')))
      GeneralMailer.recruiter_application(self, ru).deliver
    end
  end

  def to_s
    "#{[first_name, last_name].compact.join(' ')} (#{email}) for #{opening}"
  end

  def change_status(type)
    return [:alert, 'That application has not been completed.'] unless self.completed
    case type
      when 'unhire'
        return [:notice, "#{self.to_s} has not been hired."] unless self.hired
        self.hired = false
        self.began_hiring = false
        self.save
      when 'hire'
        return [:notice, "#{self.to_s} has already been hired."] if self.hired
        return [:notice, "The hiring process for #{self.to_s} has not yet begin."] unless self.began_hiring
        self.hired = true
        self.save
        return [:notice, "#{self.to_s} hired."]
      when 'begin'
        return [:notice, "#{self.to_s} has already been hired."] if self.hired
        return [:notice, "#{self.to_s} has already started the hiring process"] if self.began_hiring
        self.began_hiring = true
        self.save
        NewHireRequest.find_all_by_opening_id(self.opening_id).each do |nhr|
          nhr.update_attribute(:filled_time, Time.now)
        end
        self.opening.update_attributes({:active => false, :show_on_opp => false})
        return [:notice, "Hiring process for #{self.to_s} started."]
      when 'stop'
        return [:notice, "#{self.to_s} has already been hired."] if self.hired
        return [:notice, "#{self.to_s} is not currently in the hiring process"] unless self.began_hiring
        self.began_hiring = false
        self.hired = false
        self.save
        return [:notice, "Hiring process for #{self.to_s} terminated."]
    end
  end

  def generate_paperwork(type)
    compilable_templates = []
    separate_templates = []
    linker = case type
               when 'pre'
                 :pre_dynamic_file_links
               when 'post'
                 :post_dynamic_file_links
             end
    self.opening.send(linker).each do |fl|
      case fl.file.class.name
        when 'DynamicFormGroup'
          fl.file.dynamic_files.each do |df|
            if df.current_version.can_be_compiled
              compilable_templates << df.current_version
            else
              separate_templates << df.current_version
            end
          end
        when 'DynamicFile'
          if fl.file.current_version.can_be_compiled
            compilable_templates << fl.file.current_version
          else
            separate_templates << fl.file.current_version
          end
      end
    end

    if (state = self.applicant.try(:state))
      DynamicFile.where("#{type}_state".to_sym => state).each do |df|
        if df.current_version.can_be_compiled
          compilable_templates << df.current_version
        else
          separate_templates << df.current_version
        end
      end
    end

    compilable_templates.uniq!
    separate_templates.uniq!

    location = File.join(Rails.root.to_s, 'tmp', 'submissions', self.id.to_s, type)
    FileUtils.rm_rf(location)
    FileUtils.mkdir_p(location)
    FileUtils.mkdir_p(File.join(location, 'compilations'))
    FileUtils.mkdir_p(File.join(location, 'separates'))

    compiled_files = []

    compilable_templates.each_with_index do |ct, i|
      ct.generate_file_with_form(self.applicant, c = File.join(location, 'compilations', i.to_s))
      compiled_files << c
    end

    `pdftk #{compiled_files.collect{|cf| "\"#{cf}\""}.join(' ')} cat output "#{compiled_file = File.join(location, type == 'pre' ? 'Pre-Employment Packet.pdf' : 'Post-Hiring Packet.pdf')}"`

    separate_templates.each do |st|
      FileUtils.cp_r(st.dynamic_file_store.current_path, File.join(location, 'separates', "#{st.dynamic_file.name}.pdf"))
      #st.generate_file_with_form(self.applicant, File.join(location, 'separates', "#{st.dynamic_file.name}.pdf"))
    end

    puts compiled_file

    Zip::ZipFile.open(t = File.join(location, 'compilation.zip'), Zip::ZipFile::CREATE) do |z|
      if File.exists?(compiled_file)
        z.add(File.basename(compiled_file), compiled_file)
      end
      Dir.glob(File.join(location, 'separates', '*')).each do |s|
        z.add(File.basename(s), s)
      end
    end

    return t


    #t = Tempfile.new("submission-#{type}-#{Time.now.to_i}")
    #Zip::ZipOutputStream.open(t.path) do |z|
    #  if File.exists?(compiled_file)
    #    z.put_next_entry(File.basename(compiled_file))
    #    z.print IO.read(compiled_file)
    #  end
    #  Dir.glob(File.join(location, 'separates', '*')).each do |s|
    #    z.put_next_entry(File.basename(s))
    #    z.print IO.read(s)
    #  end
    #end
    #t
  end

  def self.indexed_attributes
    [:first_name, :last_name]
  end
end
