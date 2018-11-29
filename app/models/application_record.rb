class ApplicationRecord < ActiveRecord::Base
  require 'redcarpet/render_strip'

  self.abstract_class = true

  # TODO: review
  def markdown(str, plain: false)
    return "" if str.blank?
    options = { hard_wrap: true,
                space_after_headers: true, fenced_code_blocks: true,
                tables: true, footnotes: true,
                link_attributes: { target: '_blank', rel: 'noopener' } }

    extensions = { autolink: true, disable_indented_code_blocks: true }

    renderer = if plain
                 Redcarpet::Render::StripDown
               else
                Redcarpet::Render::HTML.new(options)
               end
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(str)
  end

  # TODO: refactor
  def generate_slug(obj, col, n = 1)
    return nil unless col
    slug = col.parameterize
    slug += "-#{n}" if n > 1
    return slug unless obj.class.find_by(slug: slug)
    generate_slug(obj, col, n + 1)
  end

  def hashid
    @hashid = HASHID.encode(id)
  end

  def self.find_by_hashid(hashid)
    find_by id: HASHID.decode(hashid)
  end
end
