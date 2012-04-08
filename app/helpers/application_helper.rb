module ApplicationHelper
  def additional_commands(resource)
    case controller_name
      when 'openings'
        c = []
        if resource.active?
          c << link_to("Deactivate", change_opening_status_path(:id => resource.id, :new_status => 'inactive'))
        else
          c << link_to("Activate", change_opening_status_path(:id => resource.id, :new_status => 'active'))
          if resource.show_on_opp
            c << link_to("Remove from OPP", change_opening_status_path(:id => resource.id, :new_status => 'hide_opp'))
          else
            c << link_to("Show on OPP", change_opening_status_path(:id => resource.id, :new_status => 'show_opp'))
          end
        end
        raw " &middot; #{c.join(" &middot; ")}"
      else

    end
  end


  def current_user
    @current_user ||= RemoteUser.find_by_id(session[:current_user])
  end

  def bio_submission_fields
    [
        ['First Name*', :first_name],
        ['Last Name*', :last_name],
        ['Preferred Name', :preferred_name],
        ['Home Phone', :home_phone],
        ['Cell Phone', :cell_phone],
        ['Email*', :email],
        ['Address Line 1', :address_1],
        ['Address Line 2', :address_2],
        ['City', :city],
        ['State', :state, :select, grouped_options_for_select(Vae::STATES)],
        ['Zip', :zip],
        ['Country', :country]
    ]
  end

  def get_question_field(g, sa)
    case sa.question_type
      when 'Yes/No'
        raw "#{g.radio_button :answer, true} Yes #{g.radio_button :answer, false} No"
      when 'Multiple Choice'
        g.select :answer, sa.question.choices.to_s.gsub(/(\r|\\r)/, '').split(/\\n/)
      when 'Small Text Box'
        g.text_field :answer
      when 'Medium Text Box'
        g.text_area :answer, :class => 'med_text_box'
      when 'Month'
        g.select :answer, %w(January February March April May June July August September October November December)
      when 'Year'
        g.select :answer, Time.now.year.downto(Time.now.year - 100).to_a
      when 'Label'
        raw ' &nbsp; '
      when 'Date'
        g.date_field :answer
    end
  end
end

module ActionView
  module Helpers
    module FormHelper
      def date_field(object_name, method, options = {})
       raw <<-OUTPUT
          #{tag = text_field(object_name, method, options)}
          <script type="text/javascript">
          $(document).ready(function(ev) {
            $("##{tag.match(/id="([^"]+)"/)[1]}").datepicker({showOtherMonths: true, selectOtherMonths: true, dateFormat: 'yy-mm-dd'});
          })
          </script>
        OUTPUT
      end
    end

    module FormTagHelper
      def date_field_tag(name, value = nil, options = {})
        raw <<-OUTPUT
        #{tag :input, { "type" => "text", "name" => name, "id" => sanitize_to_id(name), "value" => value }.update(options.stringify_keys)}
          <script type="text/javascript">
          $(document).ready(function(ev) {
            $("##{sanitize_to_id(name)}").datepicker({showOtherMonths: true, selectOtherMonths: true, dateFormat: 'yy-mm-dd'});
          })
          </script>
        OUTPUT
      end
    end

    class FormBuilder
      def date_field(method, options = {})
        @template.send(
          'date_field',
          @object_name,
          method,
          objectify_options(options))
      end
    end
  end
end
