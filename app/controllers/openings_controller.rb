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

    session[:openings] ||= {}

    session[:openings].reverse_merge!({:position => 0, :state => '', :country => '', :sort_type => "positions.name", :sort_order => "ASC"})
    session[:openings].merge!(params[:openings] || {})

    @openings = @openings.order("#{session[:openings][:sort_type]} #{session[:openings][:sort_order]}")

    if pt = PositionType.find_by_id(session[:openings][:position].to_i)
      @openings = @openings.where(["positions.position_type_id = ?", pt.id])
    end
    unless session[:openings][:state].blank?
      @openings = @openings.where(["departments.state = ?", session[:openings][:state]])
    end
    case session[:openings][:country]
      when 'USA'
        @openings = @openings.where(["departments.state in (?)", Vae::STATES['states'].collect{|k,v| v}])
      when 'CAN'
        @openings = @openings.where(["departments.state in (?)", Vae::STATES['provinces'].collect{|k,v| v}])
    end
  end

  def view
    unless @opening = Opening.find_by_id(params[:id])
      flash[:alert] = "I could not find an opening with that information."
      redirect_to root_path
    end
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