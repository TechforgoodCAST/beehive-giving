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
    hiddenQuestions = $('#beneficiaries_other')
    if $('#profile_beneficiaries_other_required:checked').length > 0
      hiddenQuestions.removeClass 'uk-hidden'
    else
      hiddenQuestions.addClass 'uk-hidden'

  otherFieldToggle = ->
    selector = '#profile_beneficiaries_other_required'
    elem     = $(selector)
    return unless elem.length > 0
    triggerOtherFieldToggle(elem.val())
    $(document).on 'change', selector, ->
      triggerOtherFieldToggle(elem.val())

  # triggerHiddenQuestionsToggle = ->
  #   hiddenQuestions = $('#hidden_questions')
  #   if $('#people:checked').length > 0
  #     hiddenQuestions.removeClass 'uk-hidden'
  #   else
  #     hiddenQuestions.addClass 'uk-hidden'
  #
  # bindHiddenQuestionsToggle = ->
  #   selector = '#people'
  #   elem     = $(selector)
  #   return unless elem.length > 0
  #   triggerHiddenQuestionsToggle(elem.val())
  #   $(document).on 'change', selector, ->
  #     triggerHiddenQuestionsToggle(elem.val())

  # bindGetTooltip = ->
  #   return $('.checkbox label').append('<i class="uk-icon-question-circle" style="float: right;" data-uk-tooltip="{pos:"top"}" title="Tooltip"></i>')

  highlightChecked = (elem) ->
    $('.' + elem + ' label :checked').closest('label').addClass(elem + '-checked')
    $('.' + elem + ' label input').change ->
      $('.' + elem + ' label').closest('label').removeClass(elem + '-checked')
      $('.' + elem + ' label :checked').closest('label').addClass(elem + '-checked')

  toggleMoreBeneficiaryOptions = ->
    $(d).on 'click', '.more-options', ->
      $('#more-beneficiary-options').toggleClass('uk-hidden')
      $('#more-beneficiary-options').addClass 'fade-in'

  return {
    bindCountryRegions: bindCountryRegions,
    otherFieldToggle: otherFieldToggle,
    # bindGetTooltip: bindGetTooltip,
    toggleMoreBeneficiaryOptions: toggleMoreBeneficiaryOptions,
    highlightChecked: highlightChecked
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
  ProfileForm.highlightChecked('checkbox')
  ProfileForm.highlightChecked('radio')
  ProfileForm.otherFieldToggle()
  # ProfileForm.bindGetTooltip()
