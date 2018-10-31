module ApplicationHelper
  def allow_functional_cookies?
    session[:functional_cookies].to_s != 'false'
  end

  def allow_performance_cookies?
    session[:performance_cookies].to_s != 'false'
  end

  def collection_title(collection)
    "New #{collection.class.to_s.downcase} report for #{collection.name}"
  end

  def obscure_email(email)
    email.gsub(/(?<=.{2})(.*)@/, '...@')
  end

  def primary_color(collection)
    collection&.primary_color || '#3B88F5' # rich-blue
  end

  def secondary_color(collection)
    collection&.secondary_color || '#1C4073' # dark-blue
  end
end
