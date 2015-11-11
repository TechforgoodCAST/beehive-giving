$(document).ready ->
  if $('#time_line').length
    createStoryJS
      type: "timeline"
      width: "100%"
      height: "400"
      source: $('#time_line').data('grants')
      embed_id: "time_line"

# $ ->
#   chart = c3.generate(
#     bindto: '#chart'
#     data: {
#         json:
#           amount_awarded: $('#chart').data('grants')
#       }
#   )

# refactor
$(document).ready ->
  if $('#funding_frequency_distribution').length
    Morris.Bar
      element: 'funding_frequency_distribution'
      data: $('#funding_frequency_distribution').data('data')
      xkey: 'target'
      ykeys: ['grant_count']
      labels: ['No. of grants']
      barColors: ['#F7BA0E']
      resize: true
      hideHover: 'auto'

# refactor?
$(document).ready ->
  if $('#multiple_funding_frequency_distribution').length
    Morris.Bar
      element: 'multiple_funding_frequency_distribution'
      data: $('#multiple_funding_frequency_distribution').data('data')
      xkey: 'target'
      ykeys: ['funder1', 'funder2', 'funder3', 'funder4', 'funder5']
      labels: [gon.funderName1, gon.funderName2, gon.funderName3, gon.funderName4, gon.funderName5]
      barColors: ['#FFD452', '#75A3D1', '#E05151', '#77BA9B', '#9C6A8D']
      resize: true
      hideHover: 'auto'
      gridTextSize: 10

# refactor?
FundersIndex = ((w, d) ->
  triggerFundersToggle = ->
    $('#toggle_funders').on 'click', ->
      $('#search_results').removeClass 'uk-hidden'
      $(this).bind 'ajax:complete', ->
        $('#suitable_funders').addClass 'uk-hidden'
        $(this).prop('disabled', true).removeAttr('data-disable-with')
        $(this).addClass 'uk-hidden'

  return { triggerFundersToggle: triggerFundersToggle }
)(window, document)

$(document).ready ->
  FundersIndex.triggerFundersToggle()
