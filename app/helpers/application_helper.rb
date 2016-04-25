module ApplicationHelper
  def title page_title
    content_for :title, page_title.to_s
  end

  def flash_class level
    case level
      when :notice then "alert-info"
      when :error then "alert-error"
      when :alert then "alert-warning"
      when :success then "alert-success"
    end
  end

  def datetime_format object, format
    object ? l(object, format: t("events.time.formats.#{format}")) : nil
  end

  def get_avatar user
    url = user.avatar.exists? ? user.avatar.url(:small) : image_path("user.png")
    image_tag(url, alt: user.name, class: "img-circle")
  end
end
