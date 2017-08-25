class ArticleCell < Cell::ViewModel
  property :title
  property :body_html

  def index
    render
  end
end
