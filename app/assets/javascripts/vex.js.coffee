vex.defaultOptions.className = 'vex-theme-plain'

@CustomDialogs = ((w, d) ->
  triggerCustomConfirm = (element) ->
    $('.' + element).click (e) ->
      e.preventDefault()
      e.stopPropagation()

      message = 'This is NOT one of your recommended (<i class="uk-icon uk-icon-star uk-icon-small yellow"></i>) funders, do you want to continue?' if element == 'unsuitable'

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

$(document).ajaxComplete ->
  CustomDialogs.triggerCustomConfirm('unsuitable')
