module ApplicationHelper
  def nav_active(action, style)
    if action == action_name
      return "<li class=\"#{style}\">"
    else
      return "<li>"
    end
  end
    
end
