$.fn.digits = ->
  @each ->
    $(this).text $(this).text().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,')
    return

$.fn.currencyFormat = ->
  @each (i) ->
    $(this).change (e) ->
      if isNaN(parseFloat(@value))
        return
      @value = parseFloat(@value).toFixed(2)
      console.log 'hello'
      return
    return
  this

$(document).ready ->
  $('#proposal_activity_costs, #proposal_people_costs, #proposal_capital_costs, #proposal_other_costs').on 'input', ->
    $('.currency input').currencyFormat()
    activity_costs = parseFloat($("#proposal_activity_costs").val())
    people_costs = parseFloat($("#proposal_people_costs").val())
    capital_costs = parseFloat($("#proposal_capital_costs").val())
    other_costs = parseFloat($("#proposal_other_costs").val())

    $('.total').html(((activity_costs || 0) + (people_costs || 0) + (capital_costs || 0) + (other_costs || 0)).toFixed(2)).digits()

  pluralize_characters = (num) ->
    if num == 1
      num + ' character'
    else
      num + ' characters'

  if $('#char_count').length > 0
    $('#char_count').text 140 - ($('#proposal_tagline').val().length) + ' characters remaining'

  $('#proposal_tagline').on 'input', ->
    chars = $('#proposal_tagline').val().length
    left = 140 - chars
    if left >= 0
      $('#char_count').removeClass('red').text pluralize_characters(left) + ' remaining'
    else
      left = left * -1
      $('#char_count').addClass('red').text('-' + pluralize_characters(left))
    return
