Modals = ((w,d) ->

  bindModalClose = (_cookieName, target) ->

    $(document).on 'click', target, ->
      if d.cookie.indexOf(_cookieName) == -1
        return d.cookie = _cookieName + '=true'
      return

  return { bindModalClose: bindModalClose }
)(window, document)

$(document).ready ->
  Modals.bindModalClose('_BHwelcomeClose', '.js-record-welcome-close')
  Modals.bindModalClose('_BHrecommendationClose', '.js-record-recommendation-close')
