class DynamicFilesController < ApplicationController
  before_filter :is_administrator?

  def update
    files_size = @resource.dynamic_file_revisions.size
    @resource.update_attributes(params[controller_name.singularize.to_sym])
    flash[:notice] = "#{controller_name.singularize.titleize} updated."

    redirect_to :action => :edit
  end

  def test_compile
    if (resource = DynamicFile.find_by_id(params[:id]))
      if (rev = resource.current_version)
        file = rev.generate_file_with_form
        send_file file, :filename => "#{resource.name}.pdf"
      else
        flash[:alert] = "There is no current valid revision."
        redirect_to :action => :edit
      end
    else
      flash[:alert] = 'That is not a valid file.'
      redirect_to :action => :index
    end
  end
end