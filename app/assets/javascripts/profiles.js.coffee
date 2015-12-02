$(document).ready ->
  $('.year').html($('#profile_year').val())
  $('#profile_year').change ->
    $('.year').html($('#profile_year').val())
    return

ProfileForm = ((w, d) ->

  bindCountryRegions = ->
    districts = $('#profile_district_ids').html()

    country = $('#profile_country_ids :selected')
    options = []
    $.each country, (index, value) ->
      options.push($(districts).filter("optgroup[label='#{$(value).text()}']").html())
      return
    $('#profile_district_ids').html(options).trigger("chosen:updated")

    $('#profile_country_ids').change ->
      country = $('#profile_country_ids :selected')
      options = []
      $.each country, (index, value) ->
        options.push($(districts).filter("optgroup[label='#{$(value).text()}']").html())
        return
      $('#profile_district_ids').html(options).trigger("chosen:updated")

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

  toggleMoreBeneficiaryOptions = ->
    _cookieName = '_beehiveMoreOptions'
    if d.cookie.indexOf(_cookieName) >= 0
      $('#more-beneficiary-options').removeClass('uk-hidden')
      $('.more-options').html('Less options <i class="uk-icon-caret-up"></i>')

    $('.more-options').on 'click', ->
      if d.cookie.indexOf(_cookieName) >= 0
        d.cookie = _cookieName + '=;expires=Thu, 01 Jan 1970 00:00:01 GMT;'
        # console.log(d.cookie.indexOf(_cookieName) >= 0)
        $('#more-beneficiary-options').addClass('uk-hidden')
        $('.more-options').html('More options <i class="uk-icon-caret-down"></i>')
      else
        console.log('set cookie')
        d.cookie = _cookieName + "=true"
        $('#more-beneficiary-options').removeClass('uk-hidden')
        $('#more-beneficiary-options').addClass 'fade-in'
        $('.more-options').html('Less options <i class="uk-icon-caret-up"></i>')

  # bindGetTooltip = ->
  #   return $('.checkbox label').append('<i class="uk-icon-question-circle" style="float: right;" data-uk-tooltip="{pos:"top"}" title="Tooltip"></i>')

  return {
    bindCountryRegions: bindCountryRegions,
    otherFieldToggle: otherFieldToggle,
    toggleMoreBeneficiaryOptions: toggleMoreBeneficiaryOptions,
    highlightChecked: highlightChecked
    # bindGetTooltip: bindGetTooltip,
  }
)(window, document)

$(document).ready ->
  ProfileForm.bindCountryRegions()
  ProfileForm.toggleMoreBeneficiaryOptions()
  ProfileForm.highlightChecked('checkbox')
  ProfileForm.highlightChecked('radio')
  ProfileForm.otherFieldToggle()
  # ProfileForm.bindGetTooltip()

$(document).ajaxComplete ->
  ProfileForm.bindCountryRegions()
  ProfileForm.toggleMoreBeneficiaryOptions()
  ProfileForm.highlightChecked('checkbox')
  ProfileForm.highlightChecked('radio')
  ProfileForm.otherFieldToggle()
  # ProfileForm.bindGetTooltip()
