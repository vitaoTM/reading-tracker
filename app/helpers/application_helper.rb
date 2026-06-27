module ApplicationHelper
  def format_duration(minutes)
    return "0m" if minutes.nil? || minutes == 0
    hours = minutes / 60
    mins  = minutes % 60
    if hours > 0
      "#{hours}h #{mins}m"
    else
      "#{mins}m"
    end
  end
end
