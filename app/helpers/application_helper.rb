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
end
