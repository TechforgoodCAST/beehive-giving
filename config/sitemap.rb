# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'http://www.beehivegiving.org'

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  # Pages
  add about_path
  add faq_path
  add for_funders_path
  add privacy_path
  add terms_path

  # Funds
  add public_funds_path, changefreq: 'daily'
  Fund.active.recent.limit(3).each do |fund|
    add public_fund_path(fund), lastmod: fund.updated_at
  end

  # Articles
  add articles_path
  Article.find_each do |article|
    add article_path(article), lastmod: article.updated_at
  end

  # Sessions
  add sign_in_path
end
