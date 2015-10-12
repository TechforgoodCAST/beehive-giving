SignupHelpers = ((w, d) ->

  toggleNoOrg = ->
    $('#user_job_role').change (e) ->
      if $('#user_job_role').val() == 'None, I don\'t work/volunteer for a non-profit'
        $('.organisation-declared').addClass('fade-out').addClass 'fade-in'
        $('.organisation-not-declared').removeClass('fade-out').addClass 'fade-in'
        $('.arrow-container').css 'margin-top', 29
      else
        $('.organisation-declared').removeClass 'fade-out'
        $('.organisation-not-declared').addClass 'fade-out'
        $('.arrow-container').css 'margin-top', 0
      return

  hideWelcomeMessage = ->
    $(d).on 'click', '.js-record-welcome-close', ->
      $('#welcome-message').addClass('fade-out')
      $('#new-organisation-form').removeClass('uk-hidden')
      $('#new-organisation-form').addClass('fade-in')

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
    hideWelcomeMessage: hideWelcomeMessage,
    bindRegistrationToggle: bindRegistrationToggle
  }
)(window, document)

$(document).ready ->
  SignupHelpers.toggleNoOrg()
  SignupHelpers.hideWelcomeMessage()
  SignupHelpers.bindRegistrationToggle()

$(document).ajaxComplete ->
  SignupHelpers.toggleNoOrg()
  SignupHelpers.hideWelcomeMessage()
  SignupHelpers.bindRegistrationToggle()
