class NewProposalLinksCell < Cell::ViewModel
  property :recipient

  def dashboard
    if model.registered? || model.complete?
      render 
    else
      render :incomplete
    end
  end

  def incomplete
    render
  end
end
