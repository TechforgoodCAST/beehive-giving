class Article < ApplicationRecord
  validates :title, :slug, :body, presence: true
  validates :slug, uniqueness: true

  def to_param
    slug
  end

  def title=(str)
    self[:title] = str&.titleize
  end

  def body_html
    markdown(body)
  end
end
