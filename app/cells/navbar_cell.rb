class NavbarCell < Cell::ViewModel
  property :organisation
  property :role

  def show
    return if controller?('sessions')
    render
  end

  private

    def logged_in?
      model != nil
    end

    def funder? # TODO: deprecated
      role == 'Funder'
    end

    def controller?(name)
      context[:controller].controller_name == name
    end

    def signed_up?
      # TODO: refactor
      organisation.nil? ||
        organisation.proposals.where.not(state: 'transferred').count.zero?
    end

    def signup?
      return if funder? # TODO: deprecated
      controller?('signup') || signed_up?
    end

    def background_color
      return unless logged_in?
      funder? ? 'funder-bg' : 'recipient-bg'
    end

    def logo
      content_tag(:a, '', href: root_path, title: 'Beehive', class: 'logo')
    end
end
