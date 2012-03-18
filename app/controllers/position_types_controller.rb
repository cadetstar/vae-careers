class PositionTypesController < ApplicationController
  before_filter :is_administrator?


  def index
    @resources = PositionType.order(:name)
  end
end