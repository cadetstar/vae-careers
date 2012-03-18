class QuestionGroupsController < ApplicationController
  before_filter :is_administrator?
end