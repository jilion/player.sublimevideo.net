module ApplicationHelper

  def page_title
    title = []
    title << "[#{Rails.env.upcase}]" unless Rails.env.production?
    title << (@page_title_prefix || 'SublimeVideo Player Admin')
    title << "- #{@page_title}" if @page_title
    h(title.compact.join(' '))
  end

  def title(title)
    @page_title = title
  end

end
