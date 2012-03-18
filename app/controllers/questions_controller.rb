class QuestionsController < ApplicationController
  before_filter :is_administrator?
end