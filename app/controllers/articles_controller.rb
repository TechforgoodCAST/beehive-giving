class ArticlesController < ApplicationController
  def index
    @articles = Article.order(created_at: :desc).page(params[:page])
  end

  def show
    @article = Article.find_by slug: params[:id]
    redirect_to articles_path unless @article
  end
end
