$.fn.digits = ->
  @each ->
    $(this).text $(this).text().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,')
    return

$.fn.currencyFormat = ->
  @each (i) ->
    $(this).change (e) ->
      if isNaN(parseFloat(@value))
        return
      @value = parseFloat(@value).toFixed(2)
      return
    return
  this

$(document).ready ->
  $('#proposal_activity_costs, #proposal_people_costs, #proposal_capital_costs, #proposal_other_costs').on 'input', ->
    $('.currency input').currencyFormat()
    activity_costs = parseFloat($("#proposal_activity_costs").val())
    people_costs = parseFloat($("#proposal_people_costs").val())
    capital_costs = parseFloat($("#proposal_capital_costs").val())
    other_costs = parseFloat($("#proposal_other_costs").val())

    $('.total').html(((activity_costs || 0) + (people_costs || 0) + (capital_costs || 0) + (other_costs || 0)).toFixed(2)).digits()

  pluralize_characters = (num) ->
    if num == 1
      num + ' character'
    else
      num + ' characters'

  if $('#char_count').length > 0
    $('#char_count').text 140 - ($('#proposal_tagline').val().length) + ' characters remaining'

  $('#proposal_tagline').on 'input', ->
    chars = $('#proposal_tagline').val().length
    left = 140 - chars
    if left >= 0
      $('#char_count').removeClass('red').text pluralize_characters(left) + ' remaining'
    else
      left = left * -1
      $('#char_count').addClass('red').text('-' + pluralize_characters(left))
    return

# refactor
ProposalForm = ((w, d) ->

  affectGeo = ->
    el = '.proposal_affect_geo'
    districts = $('.districts')
    country = $('.country')
    countries = $('.countries')
    $(el).on 'change', ->
      if $(el + ' :checked').val() == '0'
        districts.removeClass 'uk-hidden'
        country.addClass 'uk-hidden'
        countries.addClass 'uk-hidden'
      else if $(el + ' :checked').val() == '1'
        districts.removeClass 'uk-hidden'
        country.addClass 'uk-hidden'
        countries.addClass 'uk-hidden'
      else if $(el + ' :checked').val() == '2'
        districts.addClass 'uk-hidden'
        country.removeClass 'uk-hidden'
        countries.addClass 'uk-hidden'
      else if $(el + ' :checked').val() == '3'
        districts.addClass 'uk-hidden'
        country.addClass 'uk-hidden'
        countries.removeClass 'uk-hidden'


  multiSelectChecked = ->
    title = '.title input'
    item = '.item input'

    hightlight = (el, isTitle) ->
      $(el + ':checked').parent().addClass 'checked'
      $(el).on 'change', ->
        if $(this).is(':checked')
          $(this).parent().addClass 'checked'
          $(item + ':checked').parent().addClass 'checked' if isTitle
        else
          $(this).parent().removeClass 'checked'
          $(item).parent().removeClass 'checked' if isTitle

    $('.title input, .item input').on 'change', ->
      if $('.item input:checked').length > 0
        $('.title, .item').removeClass 'error'
      else
        if $('#proposal_district_ids').hasClass('field_with_errors')
          $('.title, .item').addClass 'error'

    hightlight(title, true)
    hightlight(item, false)


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


  toggleBeneficiaryGroups = (group) ->
    $('.proposal_affect_' + group).change ->
      if $('#proposal_affect_' + group + '_true:checked').length > 0
        $('#' + group + '-options').removeClass 'uk-hidden'
        $('#' + group + '-error').addClass 'uk-hidden'
      else
        $('#' + group + '-options').addClass 'uk-hidden'
        $('#' + group + '-error').removeClass 'uk-hidden'


  triggerToggleBeneficiaryGroups = ->
    toggleBeneficiaryGroups('people')
    toggleBeneficiaryGroups('other')


  selectAllAges = ->
    checkBoxes = '.proposal_age_groups input'
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
    if $('#proposal_affect_' + group + '_true:checked')
      if $('#' + group + ' input:checked').length > 0
        $('#' + group + ' .proposal_' + field).removeClass('field_with_errors')
      $('#' + group + ' input').change ->
        if $('#' + group + ' input:checked').length > 0
          $('#' + group + ' .proposal_' + field).removeClass('field_with_errors')
        else
          $('#' + group + ' .proposal_' + field).addClass('field_with_errors')


  triggerCheckboxErrors = ->
    showCheckboxErrors('people', 'beneficiaries')
    showCheckboxErrors('age_groups', 'age_groups')
    showCheckboxErrors('other', 'beneficiaries')
    otherRequiredErrors()


  otherRequiredErrors = ->
    $('#other input, #proposal_beneficiaries_other_required').change ->
      if $('#proposal_beneficiaries_other_required').is(':checked') || $('#other input:checked').length > 0
        $('#other .proposal_beneficiaries').removeClass('field_with_errors')
      else
        $('#other .proposal_beneficiaries').addClass('field_with_errors')


  triggerFunctions = ->
    $('.currency input').currencyFormat()
    $('#proposal_district_ids').treeMultiselect()
    triggerToggleBeneficiaryGroups()
    highlightChecked('checkbox')
    highlightChecked('radio')
    otherFieldToggle()
    triggerCheckboxErrors()
    selectAllAges()
    bindCountryRegions()
    showCountries()
    affectGeo()
    multiSelectChecked()

  return {
    triggerFunctions: triggerFunctions
  }
)(window, document)

$(document).ready ->
  ProposalForm.triggerFunctions()

$(document).ajaxComplete ->
  ProposalForm.triggerFunctions()
