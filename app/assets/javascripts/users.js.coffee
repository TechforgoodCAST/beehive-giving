vex.defaultOptions.className = 'vex-theme-plain'

@CustomDialogs = ((w, d) ->
  triggerCustomConfirm = (element) ->
    $('.' + element).click (e) ->
      e.preventDefault()
      e.stopPropagation()

      message = 'This is NOT one of your recommended funders, do you want to continue?' if element == 'unsuitable'
      message = 'This will use one of your eligibility checks.' if element == 'check-eligibility'

      link = $(this).attr('href')
      vex.dialog.confirm
        message: message
        callback: (value) ->
          if value
            window.location.href = link
            return true
          else
            return false

  return { triggerCustomConfirm: triggerCustomConfirm }
)(window, document)

$(document).ready ->
  CustomDialogs.triggerCustomConfirm('unsuitable')
  CustomDialogs.triggerCustomConfirm('check-eligibility')

$(document).ajaxComplete ->
  CustomDialogs.triggerCustomConfirm('unsuitable')
