# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  Morris.Line
    element: 'grants_chart'
    data: $('#grants_chart').data('grants')
    xkey: 'approved_on'
    ykeys: ['amount_awarded']
    labels: ['Amount awarded']
