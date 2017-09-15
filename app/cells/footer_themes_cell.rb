class FooterThemesCell < Cell::ViewModel
  def show
    render locals: {themes: get_top_themes, proposal: options[:proposal]}
  end

  private

    def get_top_themes
      Theme.joins(:funds)
           .group(:id)
           .order('COUNT(funds.id) DESC')
           .limit(4)
    end

end
