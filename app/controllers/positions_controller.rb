class PositionsController < ApplicationController
  before_filter :is_administrator?
end