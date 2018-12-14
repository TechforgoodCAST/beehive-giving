module MarkdownMethod
  extend ActiveSupport::Concern

  require 'redcarpet/render_strip'

  included do
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
  end
end
