class UserFormCell < Cell::ViewModel
  def show
    render locals: { f: options[:f] }
  end
end
