ProfileForm = ((w, d) ->

  bindCountryRegions = ->
    districts = $('.district_field').html()

    populateDistrictsList = ->
      country = $('.country_field :selected')
      options = []
      $.each country, (index, value) ->
        options.push($(districts).filter("optgroup[label='#{$(value).text()}']").html())
        return
      $('.district_field').html(options).trigger("chosen:updated")

    gon.orgCountry = gon.orgCountry || ''
    if gon.orgCountry.length > 0
      $('.country_field option').filter ->
        if $(this).html() == gon.orgCountry
          $(this).prop('selected', true)
    populateDistrictsList()

    $('.country_field').change ->
      populateDistrictsList()

  showCountries = ->
    _cookieName = '_bhCountries'
    toggle = ->
      $('.countries').removeClass('uk-hidden')
      $('.show-countries').addClass('fade-out')
      return
    if d.cookie.indexOf(_cookieName) >= 0
      toggle()
    else
      $('.show-countries').on 'click', (e) ->
        toggle()
        date = new Date();
        minutes = 30;
        date.setTime(date.getTime() + (minutes * 60 * 1000))
        document.cookie = _cookieName + '=true; Path=/; Expires=' + date + ';'

  triggerOtherFieldToggle = ->
    $.each $('.toggle-other'), ( index, value ) ->
      hiddenQuestions = $(value).parent().parent().parent().next()
      if $(value).is(':checked')
        hiddenQuestions.removeClass('uk-hidden')
      else
        hiddenQuestions.addClass 'uk-hidden'

  otherFieldToggle = ->
    selector = '.toggle-other'
    elem     = $(selector)
    return unless elem.length > 0
    triggerOtherFieldToggle(elem.val())
    $(document).on 'change', selector, ->
      triggerOtherFieldToggle(elem.val())
      unless $('.toggle-other:checked').length > 0
        $('.other').val('')

  highlightChecked = (elem) ->
    $('.' + elem + ' label :checked').closest('label').addClass(elem + '-checked')
    $('.' + elem + ' label input').change ->
      $('.' + elem + ' label').closest('label').removeClass(elem + '-checked')
      $('.' + elem + ' label :checked').closest('label').addClass(elem + '-checked')

  setCookie = (name, value) ->
    document.cookie = name + '=' + value + '; Path=/;'
    return

  deleteCookie = (name) ->
    document.cookie = name + '=; Path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT;'
    return

  toggleBeneficiaryGroups = (group) ->
    $('.profile_affect_' + group).change ->
      if $('#profile_affect_' + group + '_true:checked').length > 0
        $('#' + group + '-options').removeClass 'uk-hidden'
        $('#' + group + '-error').addClass 'uk-hidden'
      else
        $('#' + group + '-options').addClass 'uk-hidden'
        $('#' + group + '-error').removeClass 'uk-hidden'

  triggerToggleBeneficiaryGroups = ->
    toggleBeneficiaryGroups('people')
    toggleBeneficiaryGroups('other')

  selectAllAges = ->
    checkBoxes = '.profile_age_groups input'
    $(checkBoxes).first().change ->
      if this.checked
        $.each $(checkBoxes), ( i, v ) ->
          $(v).prop('checked', true).closest('label').addClass('checkbox-checked');
      else
        $.each $(checkBoxes), ( i, v ) ->
          $(v).prop('checked', false).closest('label').removeClass('checkbox-checked');

    options = []
    $.each $(checkBoxes).splice(1,$(checkBoxes).length-1), ( i, v ) ->
      options.push(v.id + ':checked') if i < 7
    options = options.join(', #')

    $(checkBoxes).change ->
      if $('#' + options).length == 7
        $(checkBoxes).first().prop('checked', true).closest('label').addClass('checkbox-checked');
      else
        $(checkBoxes).first().prop('checked', false).closest('label').removeClass('checkbox-checked');

  showCheckboxErrors = (group, field) ->
    if $('#profile_affect_' + group + '_true:checked')
      if $('#' + group + ' input:checked').length > 0
        $('#' + group + ' .profile_' + field).removeClass('field_with_errors')
      $('#' + group + ' input').change ->
        if $('#' + group + ' input:checked').length > 0
          $('#' + group + ' .profile_' + field).removeClass('field_with_errors')
        else
          $('#' + group + ' .profile_' + field).addClass('field_with_errors')

  triggerCheckboxErrors = ->
    showCheckboxErrors('people', 'beneficiaries')
    showCheckboxErrors('age_groups', 'age_groups')
    showCheckboxErrors('other', 'beneficiaries')
    otherRequiredErrors()

  otherRequiredErrors = ->
    $('#other input, #profile_beneficiaries_other_required').change ->
      if $('#profile_beneficiaries_other_required').is(':checked') || $('#other input:checked').length > 0
        $('#other .profile_beneficiaries').removeClass('field_with_errors')
      else
        $('#other .profile_beneficiaries').addClass('field_with_errors')

  return {
    bindCountryRegions: bindCountryRegions,
    otherFieldToggle: otherFieldToggle,
    triggerToggleBeneficiaryGroups: triggerToggleBeneficiaryGroups,
    highlightChecked: highlightChecked,
    showCountries: showCountries,
    triggerCheckboxErrors: triggerCheckboxErrors,
    selectAllAges: selectAllAges
  }
)(window, document)

$(document).ready ->
  ProfileForm.bindCountryRegions()
  ProfileForm.triggerToggleBeneficiaryGroups()
  ProfileForm.highlightChecked('checkbox')
  ProfileForm.highlightChecked('radio')
  ProfileForm.otherFieldToggle()
  ProfileForm.showCountries()
  ProfileForm.triggerCheckboxErrors()
  ProfileForm.selectAllAges()

$(document).ajaxComplete ->
  ProfileForm.bindCountryRegions()
  ProfileForm.triggerToggleBeneficiaryGroups()
  ProfileForm.highlightChecked('checkbox')
  ProfileForm.highlightChecked('radio')
  ProfileForm.otherFieldToggle()
  ProfileForm.showCountries()
  ProfileForm.triggerCheckboxErrors()
  ProfileForm.selectAllAges()
