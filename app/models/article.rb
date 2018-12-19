class Article < ApplicationRecord
  include MarkdownMethod

  validates :title, :slug, :body, presence: true
  validates :slug, uniqueness: true

  def body_html
    markdown(body)
  end

  def to_param
    slug
  end
end
