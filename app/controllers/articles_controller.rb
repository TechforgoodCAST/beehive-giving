class ArticlesController < ApplicationController
  def index
    @articles = Article.order(created_at: :desc)
  end

  def show
    @article = Article.find_by slug: params[:id]
    redirect_to articles_path unless @article
  end
end
