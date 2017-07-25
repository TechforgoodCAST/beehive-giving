SignupHelpers = ((w, d) ->

  toggleNoOrg = ->
    selector = '#user_org_type'
    message = $('.org-type-other')
    if $(selector).val() == '4'
      message.removeClass('fade-out')
    else if $(selector).val() == '-1'
      message.removeClass('fade-out')
      $('.seeking-individual').addClass 'fade-out'
    $(selector).change (e) ->
      if $(selector).val() == '4'
        message.removeClass('fade-out').addClass 'fade-in'
        $('.seeking-individual').removeClass 'fade-out'
      else if $(selector).val() == '-1'
        message.removeClass('fade-out')
        $('.seeking-individual').addClass 'fade-out'
      else
        message.addClass 'fade-out'
        $('.seeking-individual').removeClass 'fade-out'
      return

  triggerSignUpOrgNumbers = (state) ->
    charity_number = $('#charity-number')
    company_number = $('#company-number')

    if state == '1'
      company_number.addClass 'fade-out'
      charity_number.removeClass('fade-out').addClass 'fade-in'
    else if (state == '2' || state == '5')
      charity_number.addClass 'fade-out'
      company_number.removeClass('fade-out').addClass 'fade-in'
    else if state == '3'
      charity_number.removeClass('fade-out').addClass 'fade-in'
      company_number.removeClass('fade-out').addClass 'fade-in'
    else
      charity_number.addClass 'fade-out'
      company_number.addClass 'fade-out'
    return

  # refactor into utility method?
  bindSignUpOrgNumbers = ->
    selector = '#user_org_type'
    elem     = $(selector)
    triggerSignUpOrgNumbers(elem.val())
    $(d).on 'change', selector, ->
      triggerSignUpOrgNumbers(elem.val())

  hideWelcomeMessage = ->
    _cookieName = '_beehiveWelcomeClose'
    $(document).on 'click', '.js-welcome-close', ->
      d.cookie = _cookieName + "=true";

  # refactor
  triggerOrgFieldToggle = (state) ->
    required       = 'hr.uk-margin-bottom, .name, .founded-on, .website, .next'
    country        = $('.recipient-country')
    registerd_on   = $('.registered-on')
    charity_number = $('.charity-number')
    company_number = $('.company-number')
    street_address = $('.street-address')

    if parseInt(state) > -1
      $(required).removeClass('fade-out').addClass 'fade-in'
      country.removeClass('fade-out')
      if parseInt(state) == 0
        registerd_on.addClass 'fade-out'
        charity_number.addClass 'fade-out'
        company_number.addClass 'fade-out'
        street_address.removeClass('fade-out').addClass 'fade-in'
      else if parseInt(state) == 1
        registerd_on.removeClass('fade-out').addClass 'fade-in'
        charity_number.removeClass('fade-out').addClass 'fade-in'
        company_number.addClass 'fade-out'
        street_address.addClass 'fade-out'
      else if parseInt(state) == 2
        registerd_on.removeClass('fade-out').addClass 'fade-in'
        company_number.removeClass('fade-out').addClass 'fade-in'
        charity_number.addClass 'fade-out'
        street_address.addClass 'fade-out'
      else if parseInt(state) == 4
        registerd_on.addClass 'fade-out'
        charity_number.addClass 'fade-out'
        company_number.addClass 'fade-out'
        street_address.removeClass('fade-out').addClass 'fade-in'
      else if parseInt(state) == 5
        registerd_on.removeClass('fade-out').addClass 'fade-in'
        company_number.removeClass('fade-out').addClass 'fade-in'
        charity_number.addClass 'fade-out'
        street_address.addClass 'fade-out'
      else if parseInt(state) > 0
        registerd_on.removeClass('fade-out').addClass 'fade-in'
        charity_number.removeClass('fade-out').addClass 'fade-in'
        company_number.removeClass('fade-out').addClass 'fade-in'
        street_address.addClass 'fade-out'
      else
        registerd_on.addClass 'fade-out'
        street_address.addClass 'fade-out'
    else
      $(required).addClass 'fade-out'
      country.addClass 'fade-out'
      charity_number.addClass 'fade-out'
      company_number.addClass 'fade-out'
      registerd_on.addClass 'fade-out'

  # refactor into utility method?
  bindOrgFieldToggle = ->
    selector = '#recipient_org_type'
    elem     = $(selector)
    triggerOrgFieldToggle(elem.val())
    $(d).on 'change', selector, ->
      triggerOrgFieldToggle(elem.val())
      $(':input', '#new_recipient')
        .not(':button, :submit, :reset, :hidden, #recipient_org_type')
        .val('')
        .removeAttr('checked')
        .removeAttr 'selected'
        $('.find-organisation').addClass('fade-in').removeClass('fade-out')
        $('.find-success').addClass('fade-out')
      $('#recipient_country').val('').trigger('chosen:updated')

  jsSubmitForm = ->
    $('.check-numbers').click (event) ->
      event.preventDefault()
      $('form').submit()
      return

  checkFunders = ->
    selector = '#country'
    $(selector).change (e) ->
      $('#count').html($(selector).val())
      $('#result').removeClass('fade-out').addClass('fade-in')
      $('#preview').addClass('fade-out')
      return

  return {
    toggleNoOrg: toggleNoOrg,
    bindSignUpOrgNumbers: bindSignUpOrgNumbers,
    hideWelcomeMessage: hideWelcomeMessage,
    bindOrgFieldToggle: bindOrgFieldToggle,
    jsSubmitForm: jsSubmitForm,
    checkFunders: checkFunders
  }
)(window, document)

document.addEventListener 'turbolinks:load', ->
  SignupHelpers.toggleNoOrg()
  SignupHelpers.bindSignUpOrgNumbers()
  SignupHelpers.hideWelcomeMessage()
  SignupHelpers.bindOrgFieldToggle()
  SignupHelpers.jsSubmitForm()
  SignupHelpers.checkFunders()

$(document).ajaxComplete ->
  SignupHelpers.toggleNoOrg()
  SignupHelpers.bindSignUpOrgNumbers()
  SignupHelpers.hideWelcomeMessage()
  SignupHelpers.bindOrgFieldToggle()
  SignupHelpers.jsSubmitForm()
  SignupHelpers.checkFunders()
