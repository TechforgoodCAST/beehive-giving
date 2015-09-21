$(document).ready ->
  districts = $('#enquiry_district_ids').html()

  country = $('#enquiry_country_ids :selected')
  options = []
  $.each country, (index, value) ->
    options.push($(districts).filter("optgroup[label='#{$(value).text()}']").html())
    return
  $('#enquiry_district_ids').html(options).trigger("chosen:updated")

  $('#enquiry_country_ids').change ->
    country = $('#enquiry_country_ids :selected')
    options = []
    $.each country, (index, value) ->
      options.push($(districts).filter("optgroup[label='#{$(value).text()}']").html())
      return
    $('#enquiry_district_ids').html(options).trigger("chosen:updated")

EnquiriesHelpers = ((w, d) ->

  clickApproach = ->
    $('.approach-funder').on 'click', (event) ->
      fundingStream = '#' + $(event.target).parent().attr('id')
      $(fundingStream).html('<div class="cta"><h3 class="uk-margin-remove white">Nice one!</h3>We\'re taking you to the funder, once you\'re done...<a data-no-turbolink class="uk-button uk-button-primary uk-width-1-1 uk-margin-top" href="/funders">Why not check out your next funder to approach?</a></div>');

  return {
    clickApproach: clickApproach
  }
)(window, document)

$(document).ready ->
  EnquiriesHelpers.clickApproach()
