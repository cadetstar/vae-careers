class NewHireSkillsController < ApplicationController
  before_filter :is_administrator?
end