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
    return

  { toggleNoOrg: toggleNoOrg }
)(window, document)

$(document).ready ->
  SignupHelpers.toggleNoOrg()

$(document).ajaxComplete ->
  SignupHelpers.toggleNoOrg()
