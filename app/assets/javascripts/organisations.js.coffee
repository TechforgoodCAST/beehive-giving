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
      hideHover: true
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

  if $('#grants_distribution').length
    Morris.Bar({
      element: 'grants_distribution'
      data: [
        { y: '0k-10k', a: 0, b: 0 },
        { y: '10k-20k', a: 0, b: 0 },
        { y: '20k-30k', a: 40, b: 50 },
        { y: '30k-40k', a: 60, b: 50 },
        { y: '40k-50k', a: 0, b: 0 },
        { y: '50k-60k', a: 0, b: 0 },
        { y: '70k-80k', a: 0, b: 0 },
        { y: '80k-90k', a: 0, b: 0 },
        { y: '90k-100k', a: 0, b: 0 }
      ],
      xkey: 'y'
      ykeys: ['a', 'b']
      labels: ['2014', '2013']
      barColors: ['#ccc', '#F7BA0E']
      hideHover: true
      resize: true
    });

  if $('#grants_duration').length
    Morris.Bar({
      element: 'grants_duration'
      data: [
        { y: 'Jan', a: 0, b: 0 },
        { y: 'Feb', a: 0, b: 0 },
        { y: 'Mar', a: 0, b: 0 },
        { y: 'Apr', a: 0, b: 0 },
        { y: 'May', a: 0, b: 0 },
        { y: 'Jun', a: 0, b: 400 },
        { y: 'Jul', a: 332, b: 0 },
        { y: 'Aug', a: 0, b: 0 },
        { y: 'Sep', a: 0, b: 0 },
        { y: 'Oct', a: 0, b: 0 },
        { y: 'Nov', a: 364, b: 0 },
        { y: 'Dec', a: 0, b: 364 }
      ],
      xkey: 'y'
      ykeys: ['a', 'b']
      labels: ['2014', '2013']
      barColors: ['#F7BA0E', '#ccc']
      hideHover: true
      resize: true
    });

  if $('#grants_amount_category').length
    Morris.Line({
      element: 'grants_amount_category',
      data: [
        { y: '2013-06', a: 34850, b: 47322.86, c: 75000 },
        { y: '2013-12', a: 21863, b: 35411.75, c: 46946 },
        { y: '2014-07', a: 28064, b: 38662.70, c: 45349.51 },
        { y: '2014-11', a: 26896, b: 30749, c: 33450 }
      ],
      xkey: 'y',
      ykeys: ['a', 'b', 'c'],
      labels: ['Min.', 'Avg.', 'Max.'],
      lineColors: ['#ccc', '#F7BA0E', '#ccc']
      hideHover: true
      resize: true
    });

  if $('#org_age').length
    Morris.Line({
      element: 'org_age',
      data: [
        { y: '2013-06', a: 1090.00, b: 4281.14, c: 17199.00 },
        { y: '2013-12', a: 519.00, b: 1382.00, c: 3066.00 },
        { y: '2014-07', a: 357.00, b: 976.80, c: 1645.00 },
        { y: '2014-11', a: 397.00, b: 600.33, c: 762.00 }
      ],
      xkey: 'y',
      ykeys: ['a', 'b', 'c'],
      labels: ['Min.', 'Avg.', 'Max.'],
      lineColors: ['#ccc', '#F7BA0E', '#ccc']
      hideHover: true
      resize: true
    });

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
