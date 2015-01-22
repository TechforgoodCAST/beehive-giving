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
    height: "500"
    source: data
    embed_id: "time_line"

data = timeline:
  headline: "Grants recieved"
  type: "default"
  text: "<p> </p>"
  date: [
    {
      startDate: "2012,12,10"
      endDate: "2012,12,11"
      headline: "Grant 1"
      text: "£100"
      tag: "Funder 1"
    }
    {
      startDate: "2013,12,10"
      endDate: "2013,12,11"
      headline: "Grant 2"
      text: "£100"
      tag: "Funder 2"
    }
    {
      startDate: "2014,12,10"
      endDate: "2014,12,11"
      headline: "Grant 3"
      text: "£100"
      tag: "Funder 1"
    }
  ]
