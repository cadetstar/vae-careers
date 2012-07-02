class NewHireRequestsController < ApplicationController
  before_filter :is_current_user?
  before_filter :is_administrator?, :only => [:destroy]

  def index
    @new_hire_requests = {}

    @new_hire_requests[:direct] = NewHireRequest.direct(@current_user)
    @new_hire_requests[:approved] = @current_user.new_hire_requests - @new_hire_requests[:direct]

    @new_hire_requests[:awaiting] = []

    if @current_user.departments.include?(Department.find_by_code('XHR'))
      @new_hire_requests[:ready] = RemoteUser.find_by_email('dmartin@vaecorp.com').new_hire_requests
      @new_hire_requests[:eventual] = NewHireRequest.all - @new_hire_requests[:ready]
      RemoteUser.find_by_email('dmartin@vaecorp.com').supervised_departments.each do |sd|
        @new_hire_requests[:awaiting] += sd.manager.new_hire_requests
      end
      @new_hire_requests[:awaiting] -= @new_hire_requests[:ready]
    else
      @new_hire_requests[:awaiting] = @current_user.subordinate_requests
      @new_hire_requests[:awaiting] -= RemoteUser.find_by_email('dmartin@vaecorp.com').new_hire_requests
    end

    if @current_user.new_hire_expiration.to_i > 0
      @new_hire_requests.each do |k|
        @new_hire_requests[k].reject!{|nhr| nhr.updated_at < @current_user.new_hire_expiration.to_i.days.ago}
      end
    end
  end
end