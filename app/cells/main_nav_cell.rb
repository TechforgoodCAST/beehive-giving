class MainNavCell < NavbarCell
  def show
    render
  end

  private

    def active?(param)
      'active' if params[param]
    end
end
