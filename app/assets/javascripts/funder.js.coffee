$(document).ready ->
  if $('#time_line').length
    createStoryJS
      type: "timeline"
      width: "100%"
      height: "400"
      source: $('#time_line').data('grants')
      embed_id: "time_line"
