module BreadcrumbsHelper
  def breadcrumbs(hash = {}, color: 'white')
    items = []

    hash.each_with_index do |(text, link), i|
      items << tag.div('›', class: "crumb #{color}")

      opts = link.blank? ? "disabled #{color}" : color

      items << tag.a(
        tag.div(text, class: 'truncate'),
        class: "bread #{opts}", href: link
      )
    end

    return if items.empty?

    items.last.sub!('bread', 'bold bread')

    "<div class='maxw1050 mx-auto px15 fs14 lh18 mb30'>" \
    "<a href='#{root_path}' class='bread #{color}'>Home</a>" \
    "#{items.join}</div>".html_safe
  end
end
