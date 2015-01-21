# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  return $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    width: '100%'

jQuery ->
  Morris.Line
    element: 'grants_chart'
    data: $('#grants_chart').data('grants')
    xkey: 'approved_on'
    ykeys: ['amount_awarded']
    labels: ['Amount awarded']
