# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  return $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    width: '100%'

data = timeline:
  headline: "Grants recieved"
  type: "default"
  text: "<p> </p>"

  date: [
    startDate: "2012,12,10"
    endDate: "2012,12,11"
    headline: "Grant 1"
    text: "£100"
    tag: "Funder 1"
  ,
    startDate: "2013,12,10"
    endDate: "2013,12,11"
    headline: "Grant 2"
    text: "£100"
    tag: "Funder 2"
  ,
    startDate: "2014,12,10"
    endDate: "2014,12,11"
    headline: "Grant 3"
    text: "£100"
    tag: "Funder 1"
   ]

jQuery ->
  createStoryJS
    type: "timeline"
    width: "100%"
    height: "500"
    source: data
    embed_id: "time_line"
