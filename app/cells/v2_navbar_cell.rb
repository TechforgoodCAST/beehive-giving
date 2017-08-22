class V2NavbarCell < Cell::ViewModel
  property :organisation

  def show
    render locals: { type: type }
  end

  private

    def type
      options[:type] ? options[:type] : 'blue'
    end
end
