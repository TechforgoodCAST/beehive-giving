# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
timelinejs_assets = %w(
  timelineJS/fancybox_sprite.png
  timelineJS/loading.gif
  timelineJS/blank.gif
  timelineJS/overlay.png
  timelineJS/fancybox_sprite@2x.png
)
Rails.application.config.assets.precompile += timelinejs_assets

Rails.application.config.assets.precompile += %w( ckeditor/* )
