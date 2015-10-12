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

  bindCheckedItemsHighlight = ->
    return unless $('.checkbox label input:checked')
    $('.checkbox label input:checked').parent().css('background-color', '#f5fbfe')
    $('.checkbox label input').change ->
      if $(this).is(':checked')
        $(this).parent().css('background-color', '#f5fbfe')
      else
        $(this).parent().css('background-color', '#fafafa')
      return

  toggleMoreBeneficiaryOptions = ->
    $(d).on 'click', '.more-options', ->
      $('#more-beneficiary-options').toggleClass('uk-hidden')
      $('#more-beneficiary-options').addClass 'fade-in'

  return {
    bindCountryRegions: bindCountryRegions,
    # bindHiddenQuestionsToggle: bindHiddenQuestionsToggle,
    # bindGetTooltip: bindGetTooltip,
    bindCheckedItemsHighlight: bindCheckedItemsHighlight,
    toggleMoreBeneficiaryOptions: toggleMoreBeneficiaryOptions
  }
)(window, document)

$(document).ready ->
  ProfileForm.bindCountryRegions()
  # ProfileForm.bindHiddenQuestionsToggle()
  # ProfileForm.bindGetTooltip()
  ProfileForm.bindCheckedItemsHighlight()
  ProfileForm.toggleMoreBeneficiaryOptions()

$(document).ajaxComplete ->
  ProfileForm.bindCountryRegions()
  # ProfileForm.bindHiddenQuestionsToggle()
  # ProfileForm.bindGetTooltip()
  ProfileForm.bindCheckedItemsHighlight()
