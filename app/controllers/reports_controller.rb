class ReportsController < ApplicationController
  before_filter :is_administrator?
  before_filter :get_resource, :only => [:edit, :update, :destroy, :start_run, :execute_report, :view_report, :purge]


  def new
    @resource = controller_name.classify.constantize.create(:creator => current_user)
    redirect_to :action => :edit, :id => @resource.id
  end

  def start_run
    # First, determine if there are any prompt fields
    unless @resource.report_filters.collect{|rf| rf.value.blank? or rf.value.downcase == 'prompt'}.reduce(:|)
      redirect_to execute_report_path(:id => @resource.id)
    end
  end

  def execute_report
    completer = File.join(Rails.root, 'reports', 'completions', @resource.id.to_s)
    if File.exists?(completer)
      File.delete(completer)
    end
    @resource.update_attribute(:last_run, Time.now)
    @resource.delay.process(params[:values] || {})
  end

  def view_report
    if request.xhr?
      if File.exists?(File.join(Rails.root, 'reports', 'completions', @resource.id.to_s))
        @finished = true
      end
    else
      if params[:excel] and File.exists?(filename = File.join(Rails.root, 'reports', @resource.id.to_s + '.xls'))
        send_file(filename, :filename => "Report #{@resource.name}.xls")
      else
        @contents = File.read(File.join(Rails.root, 'reports', @resource.id.to_s + '.html'))
      end
    end
  end

  def purge
    number, flash[:alert] = @resource.purge_submissions
    if number > 0
      flash[:notice] = "Destroyed #{number} submissions."
    else
      flash[:notice] = 'Did not destroy any submissions.'
    end
    redirect_to reports_path
  end
end