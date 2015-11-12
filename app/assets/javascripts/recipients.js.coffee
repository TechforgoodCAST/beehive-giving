$(document).ready ->
  i = 0
  while i < 6
    if $('#funding-size-' + i).length
      Morris.Bar
        element: 'funding-size-' + i
        data: $('#funding-size-' + i).data('data')
        xkey: 'target'
        ykeys: ['grant_count']
        labels: ['No. of Grants']
        barColors: ['#F7BA0E']
        resize: true
        hideHover: 'auto'
        gridTextSize: 10
    i++

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
# $(document).ajaxComplete ->
#   InputHelpers.radioSelected()
