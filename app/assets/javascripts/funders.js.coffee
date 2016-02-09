# refactor
$(document).ready ->
  if $('#funding_frequency_distribution').length
    Morris.Bar
      element: 'funding_frequency_distribution'
      data: $('#funding_frequency_distribution').data('data')
      xkey: 'target'
      ykeys: ['grant_count']
      labels: ['No. of grants']
      barColors: ['#F7BA0E']
      resize: true
      hideHover: 'auto'

  if $('#funding_by_month').length
    fundingByMonth = Morris.Bar
      element: 'funding_by_month'
      data: $('#funding_by_month').data('data')
      xkey: 'month'
      ykeys: ['grant_count']
      postUnits: ' grants'
      labels: ['Awarded']
      barColors: ['#F7BA0E']
      resize: true
      hideHover: 'auto'
    # refactor
    $('#count').on 'click', ->
      fundingByMonth.options.ykeys = ['grant_count']
      fundingByMonth.options.postUnits = ' grants'
      fundingByMonth.options.preUnits = ''
      fundingByMonth.setData($('#funding_by_month').data('data'))
    $('#amount').on 'click', ->
      fundingByMonth.options.ykeys = ['amount_awarded']
      fundingByMonth.options.postUnits = ''
      fundingByMonth.options.preUnits = '£'
      fundingByMonth.setData($('#funding_by_month').data('data'))

  if $('#funding_duration').length
    fundingDuration = Morris.Bar
      element: 'funding_duration'
      data: $('#funding_duration').data('data')
      xkey: 'years'
      ykeys: ['grant_count']
      postUnits: ' grants'
      labels: ['Awarded']
      barColors: ['#F7BA0E']
      resize: true
      hideHover: 'auto'
    # refactor
    $('#duration_count').on 'click', ->
      fundingDuration.options.ykeys = ['grant_count']
      fundingDuration.options.postUnits = ' grants'
      fundingDuration.options.preUnits = ''
      fundingDuration.setData($('#funding_duration').data('data'))
    $('#duration_amount').on 'click', ->
      fundingDuration.options.ykeys = ['amount_awarded']
      fundingDuration.options.postUnits = ''
      fundingDuration.options.preUnits = '£'
      fundingDuration.setData($('#funding_duration').data('data'))

  if $('#funding_by_regions').length
    Morris.Bar
      element: 'funding_by_regions'
      data: $('#funding_by_regions').data('data')
      xkey: 'region'
      ykeys: ['grant_count']
      postUnits: ' grants'
      labels: ['Awarded']
      barColors: ['#F7BA0E']
      resize: true
      hideHover: 'auto'

# refactor
$(document).ready ->
  if $('#multiple_funding_frequency_distribution').length
    Morris.Bar
      element: 'multiple_funding_frequency_distribution'
      data: $('#multiple_funding_frequency_distribution').data('data')
      xkey: 'target'
      ykeys: ['funder1', 'funder2', 'funder3', 'funder4', 'funder5']
      labels: [gon.funderName1, gon.funderName2, gon.funderName3, gon.funderName4, gon.funderName5]
      barColors: ['#FFD452', '#75A3D1', '#E05151', '#77BA9B', '#9C6A8D']
      resize: true
      hideHover: 'auto'
      gridTextSize: 10

FundersHelper = ((w, d) ->

  hideWelcomeMessage = ->
    _cookieName = '_beehiveFunderWelcomeClose'
    $(document).on 'click', 'li a.blue', ->
      d.cookie = _cookieName + "=true";

  showMoreRows = ->
    $('.show-more').on 'click', ->
      $(this).parent().prev().find('tr').removeClass('uk-hidden')
      $(this).addClass 'uk-hidden'

  switchFunders = ->
    $('#funder-select').on 'change', ->
      $('#funder-select').prop('disabled', true)
      slug = $(this).val()
      if slug
        window.location = '/funding/' + slug + '/' + $('.funder.nav li.active').text().trim().toLowerCase()

  toggleWelcomeOptions = ->
    $('#understand').on 'click', ->
      $('#understand-options').toggle()
      $('#connect').toggle()

  return {
    hideWelcomeMessage: hideWelcomeMessage,
    showMoreRows: showMoreRows,
    switchFunders: switchFunders
  }
)(window, document)

$(document).ready ->
  FundersHelper.hideWelcomeMessage()
  FundersHelper.showMoreRows()
  FundersHelper.switchFunders()
