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
