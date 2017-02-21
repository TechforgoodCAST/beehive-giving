class SecondaryNavCell < NavbarCell
  def show
    render
  end

  private

    def funder_dropdown # TODO: deprecated
      'funder-dropdown' if funder?
    end
end
