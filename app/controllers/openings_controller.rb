class OpeningsController < ApplicationController
  before_filter :is_administrator?, :except => [:public, :view, :share]
  before_filter :get_resource, :only => [:edit, :update, :destroy, :change_status, :set_question_groups, :view_demographics, :share]

  layout :choose_layout

  def index
    super
    @additional_link = view_context.link_to('All Demographics', all_demographics_path)
  end

  def set_question_groups
    (params[:items] || []).each_with_index do |qg_id,i|
      if qg = QuestionGroup.find_by_id(qg_id)
        ogc = OpeningGroupConnection.find_or_create_by_opening_id_and_question_group_id(@resource.id, qg.id)
        ogc.group_order = i + 1
      end
    end
    OpeningGroupConnection.where(['opening_id = ? and question_group_id not in (?)', @resource.id, (params[:question_groups] || [-1])]).each do |old_qg|
      old_qg.destroy
    end
    render :text => ''
  end

  def change_status
    case params[:new_status]
      when 'show_opp'
        @resource.active = false
        @resource.show_on_opp = true
      when 'hide_opp'
        @resource.active = false
        @resource.show_on_opp = false
      when 'active'
        @resource.active = true
        @resource.show_on_opp = true
        @resource.posted_at = Time.now
      when 'inactive'
        @resource.active = false
        @resource.show_on_opp = false
      else

    end
    @resource.save
    redirect_to openings_path
  end

  def get_description
    if r = Position.find_by_id(params[:id])
      render :text => r.description
    else
      render :text => ''
    end
  end

  def public
    @openings = Opening.current_openings
    @positions = PositionType.open_types
    @states = Department.states_with_departments
  end

  def view
    unless @opening = Opening.public.find_by_id(params[:id])
      flash[:alert] = "I could not find an opening with that information."
      redirect_to root_path
    end
  end

  def open_positions_posting
    openings = Opening.where(:active => true).joins(:department)

    pdf = Prawn::Document.new
    pdf.font_size 48
    pdf.font pdf.font.name, :style => :bold
    pdf.image File.join(Rails.root, 'app', 'assets', 'images', 'vae_logo_new_smaller.jpg'), :at => [0, pdf.bounds.height], :position => :left, :vposition => :top, :width => 100
    pdf.image File.join(Rails.root, 'app', 'assets', 'images', 'vae_logo_new_smaller.jpg'), :at => [pdf.bounds.width - 100, pdf.bounds.height], :position => :left, :vposition => :top, :width => 100
    pdf.text_box "Open Positions Posting", :align => :center, :at => [(pdf.bounds.width - 100) / 2, pdf.bounds.height], :width => 100, :height => 100, :overflow => :shrink_to_fit
    pdf.font_size 10
    pdf.text_box "Generated at #{Time.now.to_s(:with_zone)}", :align => :center, :at => [(pdf.bounds.width - 100) / 2, pdf.bounds.height - 90], :width => 100, :height => 100, :overflow => :shrink_to_fit
    pdf.move_down 140
    pdf.text_box "#{t('opp_top_note')}", :align => :center, :height => 140, :overflow => :shrink_to_fit

    pdf.font pdf.font.name, :style => :normal
    pdf.move_down 20

    classifications = Department.select('classification').all.collect{|d| d.classification}.uniq - [nil]
    classifications.sort!
    classifications << nil
    classifications.each do |c|
      these_openings = openings.where("departments.classification" => c)
      if these_openings.size > 0
        pdf.font_size 14
        pdf.text (c || 'Uncategorized').upcase, :style => :bold
        titles = these_openings.collect{|o| o.position_type}.uniq
        titles.sort!
        titles.each do |title|
          titled_openings = these_openings.select{|o| o.position_type == title}
          titled_openings.collect{|to| to.description.gsub(/ /, '').downcase}.uniq.sort.each do |d|
            data = []
            actual_description = ''
            titled_openings.select{|to| to.description.gsub(/ /, '').downcase == d}.each do |to|
              actual_description = to.description
              data << [to.time_type_abbreviation, to.position.to_s, to.department.city_state, (to.department.try(:short_name) || to.department.try(:name) || '').to_s, to.created_at.strftime('%m/%d/%Y')]
            end
            pdf.font_size 10
            t = pdf.table(data, :column_widths => [40, 180, 120, 100, 100], :cell_style => {:borders => [], :overflow => :shrink_to_fit})
            pdf.font_size 8
            pdf.text actual_description
            pdf.move_down 50
          end
        end
      end
    end

    pdf.text_box t('admins.primary.name'), :align => :center, :at => [(pdf.bounds.width - 100) / 2, 30], :width => 100
    pdf.text_box t('admins.primary.email'), :align => :center, :at => [(pdf.bounds.width - 100) / 2, 20], :width => 100
    pdf.text_box t('admins.primary.fax'), :align => :center, :at => [(pdf.bounds.width - 100) / 2, 10], :width => 100

    pdf.render_file File.join(Rails.root, 'tmp', 'opp.pdf')
    send_file File.join(Rails.root, 'tmp', 'opp.pdf'), :filename => "Open Positions Posting.pdf"
  end

  def view_all_demographics
  end

  def view_demographics

  end

  def share
    emails = params[:emails].to_s.split(/[,\n]/)
    emails.reject!{|e| e.blank?}
    puts emails.inspect
    succeeded = []
    failed = []
    if emails.size > 0
      emails.each do |e|
        begin
          GeneralMailer.opening_mail(e, current_applicant, @resource).deliver
          succeeded << e
        rescue
          failed << e
        end
      end
    end
    unless succeeded.empty?
      flash[:notice] = "Emails sent to #{succeeded.join(', ')}"
    end
    unless failed.empty?
      flash[:alert] = "Emails failed to send to #{failed.join(', ')}"
    end
    redirect_to root_path
  end

  private
  def choose_layout
    case action_name
      when 'public', 'view'
        'public'
      else
        'application'
    end
  end
end