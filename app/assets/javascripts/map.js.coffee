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

  $.getJSON('/map-data/' + gon.funderSlug, (data) ->
    # $('h2').append('<p>loading...</p>')
  ).done (data) ->

    # mapData = JSON.parse($('#map').attr('data'))

    # mapData = ''
    # $.ajax
    #   type: 'GET'
    #   url: '/map-data/garfield-weston-foundation'
    #   async: false
    #   success: (text) ->
    #     mapData = text
    #     return
    #
    # mapData2 = ''
    # $.ajax
    #   type: 'GET'
    #   url: '/map-data/esmee-fairbairn-foundation'
    #   async: false
    #   success: (text) ->
    #     mapData2 = text
    #     return

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
        weight: 2
        opacity: 0.1
        color: '#333'
        fillOpacity: 0.8
        fillColor: getColor(feature.properties.grant_count_hue)
      }

    # get colour depending on segment

    getColor = (d) ->
      if d == 7 then '#8c2d04' else if d == 6 then '#cc4c02' else if d == 5 then '#ec7014' else if d == 4 then '#fe9929' else if d == 3 then '#fec44f' else if d == 2 then '#fee391' else if d == 1 then '#fff7bc' else '#ffffe5'

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
      # refactor
      mapLayer.resetStyle e.target
      closeTooltip = window.setTimeout((->
        map.closePopup()
        return
      ), 100)
      return

    zoomToFeature = (e) ->
      map.fitBounds e.target.getBounds()
      layer = e.target
      content = '<div><strong>' + layer.feature.properties.name + '</strong>' +
        '<ul><li><strong>£' + (layer.feature.properties.amount_awarded).formatMoney(0) + '</strong> in <strong>' +
        layer.feature.properties.grant_count + '</strong> grant(s).</li>' +
        '<li>Average grant of <strong>£' + layer.feature.properties.grant_average + '</strong>.</li></ul>'
      info.innerHTML = content
      return

    getLegendHTML = ->
      grades = [0, 1, 2, 3, 4, 5, 6, 7]
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
    map = L.mapbox.map('map', 'mapbox.light').addControl(L.mapbox.geocoderControl('mapbox.places')).setView([54.515, -4.296], 6)
    popup = new (L.Popup)(autoPan: false)

    # mapLayer = L.geoJson(mapData,
    #   style: getStyle
    #   onEachFeature: onEachFeature).addTo(map)
    closeTooltip = undefined

    # $('#esmee').on 'click', (e) ->
    #   mapLayer = L.geoJson(mapData2,
    #     style: getStyle
    #     onEachFeature: onEachFeature).addTo(map)

    mapLayer = L.geoJson(data,
      style: getStyle
      onEachFeature: onEachFeature).addTo(map)

    # $('#count').on 'click', (e) ->
    #   $.getJSON('/map-data/esmee-fairbairn-foundation', (data) ->
    #     console.log 'loading...'
    #     return
    #   ).done( (data) ->
    #     mapLayer = L.geoJson(data,
    #       style: getStyle
    #       onEachFeature: onEachFeature).addTo(map)
    #     return
    #   )

    $('#all').on 'click', (e) ->
      mapLayer.setStyle getStyle

    $('#count').on 'click', (e) ->
      mapLayer.setStyle getGrantCount

    # map.legendControl.addLegend getLegendHTML()

    # markerLayer = L.mapbox.featureLayer().addTo(map)

    # markers = new (L.MarkerClusterGroup)

    # geojson = JSON.parse($('#geojson').attr('data'))

    # markers.addLayer(L.geoJson(geojson));
    # map.addLayer(markers)

    # markerLayer.setGeoJSON geojson
    # markerLayer.on 'mouseover', (e) ->
    #   e.layer.openPopup()
    #   return
    # markerLayer.on 'mouseout', (e) ->
    #   e.layer.closePopup()
    #   return

    info = document.getElementById('info')
    # myLayer = L.mapbox.featureLayer().addTo(map)
    # myLayer.setGeoJSON(geojson)
    empty = ->
      info.innerHTML = '<div><strong>Click a region for more details</strong></div>'
      return

    # myLayer.on 'click', (e) ->
    #   e.layer.closePopup()
    #   feature = e.layer.feature
    #   content = '<div><strong>' + feature.properties.title + '</strong>' + '<p>Seeking: £' + feature.properties.seeking + '</p><p><a>More details</a></p></div>'
    #   info.innerHTML = content
    #   return
    map.on 'move', empty
    empty()

#   return
# )
