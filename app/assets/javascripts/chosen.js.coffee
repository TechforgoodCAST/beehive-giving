ChosenHelpers = ((w, d) ->

  loadChosen = ->
    return $('.chosen-select').chosen
      allow_single_deselect: true
      no_results_text: 'No results matched'
      placeholder_text_multiple: 'Select as many as applicable'
      width: '100%'

  return {
    loadChosen: loadChosen
  }
)(window, document)

$(document).ready ->
  ChosenHelpers.loadChosen()

$(document).ajaxComplete ->
  ChosenHelpers.loadChosen()
