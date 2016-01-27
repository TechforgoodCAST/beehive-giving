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

  if $('#funding_by_month').length
    Morris.Bar
      element: 'funding_by_month'
      data: $('#funding_by_month').data('data')
      xkey: 'month'
      ykeys: ['grant_count']
      postUnits: ' grants'
      labels: ['Awarded']
      barColors: ['#F7BA0E']
      resize: true
      hideHover: 'auto'

  if $('#amount_by_month').length
    Morris.Bar
      element: 'amount_by_month'
      data: $('#amount_by_month').data('data')
      xkey: 'month'
      ykeys: ['amount_awarded']
      preUnits: '£'
      labels: ['Awarded']
      barColors: ['#F7BA0E']
      resize: true
      hideHover: 'auto'

  if $('#funding_by_regions').length
    Morris.Bar
      element: 'funding_by_regions'
      data: $('#funding_by_regions').data('data')
      xkey: 'region'
      ykeys: ['grant_count']
      postUnits: ' grants'
      labels: ['Awarded']
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

FundersHelper = ((w, d) ->

  toggleSharedRecipients = ->
    $('.more-shared-recipients').on 'click', ->
      $('tr').removeClass 'uk-hidden'
      $('.more-shared-recipients').addClass 'uk-hidden'

  return { toggleSharedRecipients: toggleSharedRecipients }
)(window, document)

$(document).ready ->
  FundersHelper.toggleSharedRecipients()
