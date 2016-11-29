InputHelpers = ((w, d) ->

  radioSelected = ->
    $('.radio label :checked').closest('label').addClass('radio-checked')
    $('.radio label input').change ->
      $('.radio label').closest('label').removeClass('radio-checked')
      $('.radio label :checked').closest('label').addClass('radio-checked')

  return {
    radioSelected: radioSelected
  }
)(window, document)

$(document).ready ->
  InputHelpers.radioSelected()
