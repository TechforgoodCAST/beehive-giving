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
    $(document).on 'click', '.js-record-welcome-close', ->
      $('#welcome-message').addClass('fade-out')
      $('#new-organisation-form').removeClass('uk-hidden')
      $('#new-organisation-form').addClass('fade-in')

  return { toggleNoOrg: toggleNoOrg, hideWelcomeMessage: hideWelcomeMessage }
)(window, document)

$(document).ready ->
  SignupHelpers.toggleNoOrg()
  SignupHelpers.hideWelcomeMessage()

$(document).ajaxComplete ->
  SignupHelpers.toggleNoOrg()
  SignupHelpers.hideWelcomeMessage()
