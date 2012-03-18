class OpeningsController < ApplicationController
  before_filter :is_administrator?, :except => [:public, :view]

  layout :choose_layout
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