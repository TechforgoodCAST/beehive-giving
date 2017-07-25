document.addEventListener 'turbolinks:load', ->
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
