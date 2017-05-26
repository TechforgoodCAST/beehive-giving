class ArticleCell < Cell::ViewModel
  property :title
  property :body_html

  def index
    render
  end

  def cta
    render
  end
end
