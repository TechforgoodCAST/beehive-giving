$(document).ready ->
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

$(document).ready ->
  $('.year').html($('#profile_year').val())
  $('#profile_year').change ->
    $('.year').html($('#profile_year').val())
    return

ProfileForm = ((w, d) ->
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

  bindCheckedItemsHighlight = ->
    return unless $('.checkbox label input:checked')
    $('.checkbox label input:checked').parent().css('background-color', '#f5fbfe')
    $('.checkbox label input').change ->
      if $(this).is(':checked')
        $(this).parent().css('background-color', '#f5fbfe')
      else
        $(this).parent().css('background-color', '#fafafa')
      return

  return {
    # bindHiddenQuestionsToggle: bindHiddenQuestionsToggle,
    bindCheckedItemsHighlight: bindCheckedItemsHighlight
  }
)(window, document)

$(document).ready ->
  # ProfileForm.bindHiddenQuestionsToggle()
  ProfileForm.bindCheckedItemsHighlight()
