module ApplicationHelper
  def flash_classes(type)
    base_classes = "p-4 rounded mt-4 flash-message"
    case type
    when "notice"
      "border border-green-400 bg-green-200 text-green-800 #{base_classes}"
    when "error"
      "border border-red-400 bg-red-200 text-red-800 #{base_classes}"
    else
      base_classes
    end
  end
end
