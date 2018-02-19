class TermsNoticeCell < Cell::ViewModel
  def show
    render if model && model.terms_version != TERMS_VERSION
  end
end
