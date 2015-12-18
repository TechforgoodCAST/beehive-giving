SignupHelpers = ((w, d) ->

  toggleNoOrg = ->
    selector = $('#user_seeking')
    charity_number = $('#charity_number')
    company_number = $('#company_number')

    selector.change (e) ->
      if $('#user_seeking').val() == '1'
        company_number.addClass 'fade-out'
        charity_number.removeClass('fade-out').addClass 'fade-in'
      else if selector.val() == '2'
        charity_number.addClass 'fade-out'
        company_number.removeClass('fade-out').addClass 'fade-in'
      else if selector.val() == '3'
        charity_number.removeClass('fade-out').addClass 'fade-in'
        company_number.removeClass('fade-out').addClass 'fade-in'
      else
        charity_number.addClass 'fade-out'
        company_number.addClass 'fade-out'
      return

  hideWelcomeMessage = ->
    _cookieName = '_beehiveWelcomeClose'
    $(document).on 'click', '.js-welcome-close', ->
      d.cookie = _cookieName + "=true";

  triggerRegisteredToggle = (state)->
    founded = $('.js-founded-toggle-target')
    registered = $('.js-registered-toggle-target')
    if state == 'true'
      registered.removeClass 'uk-hidden'
      founded.removeClass 'uk-hidden'
    else if state == 'false'
      founded.removeClass 'uk-hidden'
      registered.addClass 'uk-hidden'
    else
      founded.addClass 'uk-hidden'
      registered.addClass 'uk-hidden'

  bindRegistrationToggle = ->
    selector = '.js-registered-toggle'
    elem     = $(selector)
    return unless elem.length > 0
    triggerRegisteredToggle(elem.val())
    $(d).on 'change', selector, ->
      triggerRegisteredToggle(elem.val())

  return {
    toggleNoOrg: toggleNoOrg,
    bindRegistrationToggle: bindRegistrationToggle,
    hideWelcomeMessage: hideWelcomeMessage
  }
)(window, document)

$(document).ready ->
  SignupHelpers.toggleNoOrg()
  SignupHelpers.bindRegistrationToggle()
  SignupHelpers.hideWelcomeMessage()

$(document).ajaxComplete ->
  SignupHelpers.toggleNoOrg()
  SignupHelpers.bindRegistrationToggle()
  SignupHelpers.hideWelcomeMessage()
