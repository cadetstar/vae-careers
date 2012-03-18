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

  end

  def view

  end

  private
  def choose_layout
    case action_name
      when 'public'
        'public'
      else
        'application'
    end
  end
end