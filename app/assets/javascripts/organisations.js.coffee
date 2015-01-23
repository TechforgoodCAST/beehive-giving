# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  return $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    width: '100%'

$(document).ready ->
  if $('#grants_chart').length
    Morris.Line
      element: 'grants_chart'
      data: $('#grants_chart').data('grants')
      xkey: 'approved_on'
      ykeys: ['amount_awarded']
      labels: ['Amount awarded']

$(document).ready ->
  createStoryJS
    type: "timeline"
    width: "100%"
    height: "400"
    source: $('#time_line').data('grants')
    embed_id: "time_line"
