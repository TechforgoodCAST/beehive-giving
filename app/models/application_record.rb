class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def markdown(str)
    options = { hard_wrap: true,
                space_after_headers: true, fenced_code_blocks: true,
                tables: true, footnotes: true,
                link_attributes: { target: '_blank' } }

    extensions = { autolink: true, disable_indented_code_blocks: true }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(str)
  end

  def generate_slug(obj, col, n = 1)
    return nil unless col
    slug = col.parameterize
    slug += "-#{n}" if n > 1
    return slug unless obj.class.find_by(slug: slug)
    generate_slug(obj, col, n + 1)
  end
end
