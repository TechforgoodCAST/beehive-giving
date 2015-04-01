Feedback = ((w,d) ->

  _cookieName = '_BHfeedbackClose'

  bindFormClose = ->
    $(document).on 'click', '.js-record-feedback-close', ->
      if d.cookie.indexOf(_cookieName) == -1
        return d.cookie = _cookieName + '=true'
      return

  return { bindFormClose: bindFormClose }
)(window, document)

$(document).ready ->
  Feedback.bindFormClose()
