module ProfilesHelper

  def get_year
    if @profile.year
      @profile.year
    else
      content_tag(:span, '', class: 'year')
    end
  end

end
