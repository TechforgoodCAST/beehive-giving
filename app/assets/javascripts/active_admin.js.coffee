#= require active_admin/base
#= require chosen-jquery

#= require Chart.bundle
#= require chartkick


$(document).ready ->
  return $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    placeholder_text_multiple: 'Select as many as applicable'
    width: '80%'

$(document).on 'has_many_add:after', '.has_many_container', (e, fieldset)->
  fieldset.find('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    placeholder_text_multiple: 'Select as many as applicable'
    width: '80%'
