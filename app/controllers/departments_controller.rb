class DepartmentsController < ApplicationController
  def start_query
    (Department.first || Department.create).delay.fetch_from_accounts
    render :text => ''
  end
end