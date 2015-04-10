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
