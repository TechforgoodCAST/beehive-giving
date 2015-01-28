# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  return $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    placeholder_text_multiple: 'Select as many as appropriate'
    width: '100%'

$(document).ready ->
  if $('#grants_given').length
    Morris.Bar
      element: "grants_given"
      data: [
        { y: 'Jan', a: 0, b: 0 },
        { y: 'Feb', a: 0, b: 0 },
        { y: 'Mar', a: 0, b: 0 },
        { y: 'Apr', a: 0, b: 0 },
        { y: 'May', a: 0, b: 0 },
        { y: 'Jun', a: 7, b: 0 },
        { y: 'Jul', a: 0, b: 5 },
        { y: 'Aug', a: 0, b: 0 },
        { y: 'Sep', a: 0, b: 0 },
        { y: 'Oct', a: 0, b: 0 },
        { y: 'Nov', a: 0, b: 3 },
        { y: 'Dec', a: 8, b: 0 }
      ]
      xkey: 'y'
      ykeys: ['a', 'b']
      labels: ['2013', '2014']
      barColors: ['#ccc', '#F7BA0E']
      resize: true

  if $('#grants_stages').length
    Morris.Donut
      element: 'grants_stages'
      data: [
        {label: "Enquiries", value: 48},
        {label: "Applications", value: 5},
        {label: "Grants", value: 3}
      ]
      colors: ['#eee', '#ccc', '#F7BA0E']
      resize: true


# $(document).ready ->
#   if $('#grants_chart').length
#     Morris.Line
#       element: 'grants_chart'
#       data: $('#grants_chart').data('grants')
#       xkey: 'approved_on'
#       ykeys: ['amount_awarded']
#       labels: ['Amount awarded']

$(document).ready ->
  createStoryJS
    type: "timeline"
    width: "100%"
    height: "400"
    source: $('#time_line').data('grants')
    embed_id: "time_line"
