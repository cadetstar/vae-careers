class OpeningsController < ApplicationController
  before_filter :is_administrator?, :except => [:public, :view]
  before_filter :get_resource, :only => [:edit, :update, :destroy, :change_status, :set_question_groups]

  layout :choose_layout

  def set_question_groups
    (params[:question_groups] || []).each_with_index do |qg_id,i|
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
    openings = Opening.where(:active => true)

    pdf = Prawn::Document.new
    pdf.font_size 48
    pdf.font pdf.font.name, :style => :bold
    pdf.text_box "Open Positions Posting", :align => :center, :at => [(pdf.bounds.width - 100) / 2, pdf.bounds.height], :width => 100, :height => 100, :overflow => :shrink_to_fit
    pdf.move_down 20
    pdf.font_size 12
    pdf.font pdf.font.name, :style => :normal

    titles = openings.collect{|o| o.position_type}.uniq
    titles.sort!
    titles.each do |title|
      titled_openings = openings.select{|o| o.position_type == title}
      titled_openings.collect{|to| to.description}.uniq.sort.each do |d|
        data = []
        titled_openings.select{|to| to.description == d}.each do |to|
          data << [to.department.try(:short_name), to.position.to_s, to.created_at.to_s]
        end
        pdf.table(data, :column_widths => [100, 300, 140])
        pdf.text d
        pdf.move_down 20
      end
    end

    pdf.render_file File.join(Rails.root, 'tmp', 'opp.pdf')
    send_file File.join(Rails.root, 'tmp', 'opp.pdf')
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