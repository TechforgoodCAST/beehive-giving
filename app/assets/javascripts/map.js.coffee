Number::formatMoney = (c, d, t) ->
  `var t`
  `var d`
  `var c`
  n = this
  c = if isNaN(c = Math.abs(c)) then 2 else c
  d = if d == undefined then '.' else d
  t = if t == undefined then ',' else t
  s = if n < 0 then '-' else ''
  i = parseInt(n = Math.abs(+n or 0).toFixed(c)) + ''
  j = if (j = i.length) > 3 then j % 3 else 0
  s + (if j then i.substr(0, j) + t else '') + i.substr(j).replace(/(\d{3})(?=\d)/g, '$1' + t) + (if c then d + Math.abs(n - i).toFixed(c).slice(2) else '')

$(document).ready ->

  $.getJSON('/map-data/' + gon.funderSlug).done (data) ->

    getStyle = (feature) ->
      {
        weight: 2
        opacity: 0.1
        color: '#333'
        fillOpacity: 0.8
        fillColor: getColor(feature.properties.amount_awarded_hue)
      }

    getGrantCount = (feature) ->
      {
        fillColor: getColor(feature.properties.grant_count_hue)
      }

    getRankHue = (feature) ->
      {
        fillColor: getColor(feature.properties.rank_hue)
      }

    getColor = (d) ->
      if d == 9 then '#b00026'
      else if d == 8 then '#bd0026'
      else if d == 7 then '#e31a1c'
      else if d == 6 then '#fc4e2a'
      else if d == 5 then '#fd8d3c'
      else if d == 4 then '#feb24c'
      else if d == 3 then '#fed976'
      else if d == 2 then '#ffeda0'
      else if d == 1 then '#ffffcc'
      else '#ffffe5'

    onEachFeature = (feature, layer) ->
      layer.on
        mousemove: mousemove
        mouseout: mouseout
        click: zoomToFeature
      return

    mousemove = (e) ->
      layer = e.target
      popup.setLatLng e.latlng
      popup.setContent '<div class="marker-title">' + layer.feature.properties.name + '</div>' + '<strong>£' + (layer.feature.properties.amount_awarded).formatMoney(0) + '</strong> in <strong>' + layer.feature.properties.grant_count + '</strong> grant(s).'
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
      e.target.setStyle
        weight: 2
        opacity: 0.1
        fillOpacity: 0.8
      closeTooltip = window.setTimeout((->
        map.closePopup()
        return
      ), 100)
      return

    zoomToFeature = (e) ->
      map.fitBounds e.target.getBounds()
      layer = e.target
      rank = ''
      rank = '<li>Indices rank <strong>' + layer.feature.properties.rank + '</strong> in 2015.</li><li><strong>' + layer.feature.properties.rank_proportion + '%</strong> of residents living in highly deprived areas in 2015.</li>' if layer.feature.properties.rank

      content = '<div><strong>' + layer.feature.properties.name + '</strong>' +
        '<ul><li><strong>£' + (layer.feature.properties.amount_awarded).formatMoney(0) + '</strong> in <strong>' +
        layer.feature.properties.grant_count + '</strong> grant(s).</li>' +
        '<li>Average grant of <strong>£' + Math.round(layer.feature.properties.grant_average) + '</strong>.</li>' + rank + '</ul><a href="/funding/' + gon.funderSlug + '/' + layer.feature.properties.slug + '">More info</a>'
      info.innerHTML = content
      return

    L.mapbox.accessToken = 'pk.eyJ1IjoiYmVlaGl2ZWdpdmluZyIsImEiOiJjaWZma3IyM3cwMGp6dGprbnZ1ZnVubTY1In0.sAccvZGdUQt3fHhWhrpGfw'
    map = L.mapbox.map('map', 'mapbox.light').addControl(L.mapbox.geocoderControl('mapbox.places')).setView([54.515, -4.296], 6)
    popup = new (L.Popup)(autoPan: false)

    mapLayer = L.geoJson(data,
      style: getStyle
      onEachFeature: onEachFeature).addTo(map)
    closeTooltip = undefined

    $('#all').on 'click', (e) ->
      mapLayer.setStyle getStyle

    $('#count').on 'click', (e) ->
      mapLayer.setStyle getGrantCount

    $('#rank').on 'click', (e) ->
      mapLayer.setStyle getRankHue

    info = document.getElementById('info')
    empty = ->
      info.innerHTML = '<div><strong>Click a region for more details</strong></div>'
      return
    empty()

    # map.on 'move', empty
