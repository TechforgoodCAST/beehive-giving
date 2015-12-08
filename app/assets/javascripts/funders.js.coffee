$(document).ready ->
  mapData = JSON.parse($('#map').attr('data'))

  getStyle = (feature) ->
    {
      weight: 2
      opacity: 0.1
      color: '#333'
      fillOpacity: 0.8
      fillColor: getColor(feature.properties.grant_count)
    }

  # get colour depending on grant_count

  getColor = (d) ->
    if d > 7 then '#8c2d04' else if d > 6 then '#cc4c02' else if d > 5 then '#ec7014' else if d > 4 then '#fe9929' else if d > 3 then '#fec44f' else if d > 2 then '#fee391' else if d > 1 then '#fff7bc' else '#ffffe5'

  onEachFeature = (feature, layer) ->
    layer.on
      mousemove: mousemove
      mouseout: mouseout
      click: zoomToFeature
    return

  mousemove = (e) ->
    layer = e.target
    popup.setLatLng e.latlng
    popup.setContent '<div class="marker-title">' + layer.feature.properties.name + '</div>' + 'Grants given: ' + layer.feature.properties.grant_count
    if !popup._map
      popup.openOn map
    window.clearTimeout closeTooltip
    # highlight feature
    layer.setStyle
      weight: 3
      opacity: 0.3
      fillOpacity: 0.9
    if !L.Browser.ie and !L.Browser.opera
      layer.bringToFront()
    return

  mouseout = (e) ->
    mapLayer.resetStyle e.target
    closeTooltip = window.setTimeout((->
      map.closePopup()
      return
    ), 100)
    return

  zoomToFeature = (e) ->
    map.fitBounds e.target.getBounds()
    return

  getLegendHTML = ->
    grades = [
      0
      1
      2
      3
      4
      5
      6
      7
    ]
    labels = []
    from = undefined
    to = undefined
    i = 0
    while i < grades.length
      from = grades[i]
      to = grades[i + 1]
      labels.push('<li><span class="swatch" style="background:' + getColor(from + 1) + '"></span> ' + from + (if to then '&ndash;' + to else '+')) + '</li>'
      i++
    '<span>No. of grants given</span><ul>' + labels.join('') + '</ul>'

  L.mapbox.accessToken = 'pk.eyJ1IjoiYmVlaGl2ZWdpdmluZyIsImEiOiJjaWZma3IyM3cwMGp6dGprbnZ1ZnVubTY1In0.sAccvZGdUQt3fHhWhrpGfw'
  map = L.mapbox.map('map', 'mapbox.streets').addControl(L.mapbox.geocoderControl('mapbox.places')).setView([
    54.515
    -4.296
  ], 6)
  popup = new (L.Popup)(autoPan: false)

  mapLayer = L.geoJson(mapData,
    style: getStyle
    onEachFeature: onEachFeature).addTo(map)
  closeTooltip = undefined
  map.legendControl.addLegend getLegendHTML()

#
#
#

$(document).ready ->
  if $('#time_line').length
    createStoryJS
      type: "timeline"
      width: "100%"
      height: "400"
      source: $('#time_line').data('grants')
      embed_id: "time_line"

# $ ->
#   chart = c3.generate(
#     bindto: '#chart'
#     data: {
#         json:
#           amount_awarded: $('#chart').data('grants')
#       }
#   )

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
    Morris.Bar
      element: 'funding_by_month'
      data: $('#funding_by_month').data('data')
      xkey: 'month'
      ykeys: ['grant_count']
      postUnits: ' grants'
      labels: ['Awarded']
      barColors: ['#F7BA0E']
      resize: true
      hideHover: 'auto'

  if $('#amount_by_month').length
    Morris.Bar
      element: 'amount_by_month'
      data: $('#amount_by_month').data('data')
      xkey: 'month'
      ykeys: ['amount_awarded']
      preUnits: '£'
      labels: ['Awarded']
      barColors: ['#F7BA0E']
      resize: true
      hideHover: 'auto'

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

# refactor?
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

# refactor?
FundersIndex = ((w, d) ->
  triggerFundersToggle = ->
    $('#toggle_funders').on 'click', ->
      $('#search_results').removeClass 'uk-hidden'
      $(this).bind 'ajax:complete', ->
        $('#suitable_funders').addClass 'uk-hidden'
        $(this).prop('disabled', true).removeAttr('data-disable-with')
        $(this).addClass 'uk-hidden'

  return { triggerFundersToggle: triggerFundersToggle }
)(window, document)

$(document).ready ->
  FundersIndex.triggerFundersToggle()
