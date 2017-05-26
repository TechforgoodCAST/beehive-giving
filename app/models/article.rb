class Article < ActiveRecord::Base
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

  private

    def markdown(str)
      options = { filter_html: true, hard_wrap: true,
                  space_after_headers: true, fenced_code_blocks: true,
                  link_attributes: { target: '_blank' } }

      extensions = { autolink: true, disable_indented_code_blocks: true }

      renderer = Redcarpet::Render::HTML.new(options)
      markdown = Redcarpet::Markdown.new(renderer, extensions)

      markdown.render(str)
    end
end
