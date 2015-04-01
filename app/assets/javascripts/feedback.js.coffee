Feedback = ((w,d) ->

  _cookieName = '_BHfeedbackClose'

  bindFormClose = ->
    $(document).on 'click', '.js-record-feedback-close', ->
      d.cookie = _cookieName + "=true";

  return { bindFormClose: bindFormClose }
)(window, document)

$(document).ready ->
  Feedback.bindFormClose()
