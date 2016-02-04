module ApplicationHelper
  def nav_active(action, controller, style)
    if (action == action_name) && (controller == controller_name)
      return "<li class=\"#{style}\">"
    else
      return "<li>"
    end
  end
    
end
