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

  if $('#district_imd').length
    Morris.Bar
      element: 'district_imd'
      data: $('#district_imd').data('data')
      xkey: 'category'
      ykeys: ['rank']
      ymax: 326
      labels: ['Rank']
      barColors: ['#F7BA0E']
      resize: true
      hideHover: 'auto'

  if $('#region_comparison').length
    regionComparison =Morris.Bar
      element: 'region_comparison'
      data: $('#region_comparison').data('data')
      xkey: 'district'
      ykeys: ['grant_count']
      postUnits: ' grants'
      labels: ['Awarded']
      barColors: (row) ->
        if gon.districtLabel == row.label
          return ['#42b0c1']
        else
          return ['#F7BA0E']
      resize: true
      hideHover: 'auto'
      # refactor
      $('#region_comparison_count').on 'click', ->
        $('.region-comparison-count-insight').removeClass('fade-out').addClass('fade-in')
        $('.region-comparison-amount-insight').addClass('fade-out')
        regionComparison.options.ykeys = ['grant_count']
        regionComparison.options.postUnits = ' grants'
        regionComparison.options.preUnits = ''
        regionComparison.setData($('#region_comparison').data('data'))
      $('#region_comparison_amount').on 'click', ->
        $('.region-comparison-amount-insight').removeClass('fade-out').addClass('fade-in')
        $('.region-comparison-count-insight').addClass('fade-out')
        regionComparison.options.ykeys = ['amount_awarded']
        regionComparison.options.postUnits = ''
        regionComparison.options.preUnits = '£'
        regionComparison.setData($('#region_comparison').data('data'))

  if $('#funding_in_region').length
    fundingRegion = Morris.Bar
      element: 'funding_in_region'
      data: $('#funding_in_region').data('data')
      xkey: 'funder'
      ykeys: ['grant_count']
      postUnits: ' grants'
      labels: ['Awarded']
      barColors: (row) ->
        if gon.funderName == row.label
          return ['#42b0c1']
        else
          return ['#F7BA0E']
      resize: true
      hideHover: 'auto'
    # refactor
    $('#region_count').on 'click', ->
      fundingRegion.options.ykeys = ['grant_count']
      fundingRegion.options.postUnits = ' grants'
      fundingRegion.options.preUnits = ''
      fundingRegion.setData($('#funding_in_region').data('data'))
    $('#region_amount').on 'click', ->
      fundingRegion.options.ykeys = ['amount_awarded']
      fundingRegion.options.postUnits = ''
      fundingRegion.options.preUnits = '£'
      fundingRegion.setData($('#funding_in_region').data('data'))

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
    return unless window.location.pathname.split('/')[1] == 'funders'
      _cookieName = '_beehiveFunderWelcomeClose'
      modal = $.UIkit.modal("#welcome")
      modal.options.bgclose = false
      modal.options.keyboard = false

      if document.cookie.indexOf(_cookieName) >= 0
        modal.hide()
      else
        modal.show()

      $(document).on 'click', 'li a.blue', ->
        d.cookie = _cookieName + "=true;path=/";

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

  switchRegions = ->
    $('#district_select').on 'change', ->
      # $('#district_select').prop('disabled', true).trigger("chosen:updated")
      slug = $(this).val()
      if slug
        window.location = window.location.pathname.replace($('.funder.nav li.active').text().trim().toLowerCase(), slug)

  return {
    hideWelcomeMessage: hideWelcomeMessage,
    showMoreRows: showMoreRows,
    switchFunders: switchFunders,
    switchRegions: switchRegions
  }
)(window, document)

$(document).ready ->
  FundersHelper.hideWelcomeMessage()
  FundersHelper.showMoreRows()
  FundersHelper.switchFunders()
  FundersHelper.switchRegions()
