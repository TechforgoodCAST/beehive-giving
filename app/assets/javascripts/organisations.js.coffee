# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  return $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    placeholder_text_multiple: 'Select as many as appropriate'
    width: '100%'

$(document).on 'uk.switcher.show', '[data-uk-tab]', ->
  $(window).trigger 'resize'
  return

$(document).ready ->
  if $('#grants_amount').length
    Morris.Line
      element: 'grants_amount'
      data: $('#grants_amount').data('grants')
      xkey: 'approved_on'
      ykeys: ['average', 'minimum', 'maximum']
      labels: ['Amount awarded']
      smooth: false
      resize: true
      lineColors: ['#F7BA0E', '#bbb', '#bbb']
      dateFormat: (x) ->
                      indexToMonth = ['Jan', 'Feb','Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'] # refactor?
                      month = indexToMonth[new Date(x).getMonth()]
                      year = new Date(x).getFullYear()
                      return month + ' ' + year
      hoverCallback: (index, options, content, row) ->
                      return '<div class="morris-hover-row-label">' + 'Grants given in ' + options.dateFormat(row.approved_on) + '</div><div>Grant size</div><span>Max: </span><b style="color: ' + options.lineColors[2] + '">' + '£' + row.maximum.toLocaleString() + ' </b></br><span>Avg: </span><b style="color: ' + options.lineColors[0] + '">' + '£' + row.average.toLocaleString() + ' </b></br><span>Min: </span><b style="color: ' + options.lineColors[1] + '">' + '£' + row.minimum.toLocaleString() + ' </b></br><span>No. of grants: </span>' + row.count
      xLabelFormat: (x) ->
                      return x.toLocaleString('en-gb', { year: 'numeric', month: 'short' })
      yLabelFormat: (y) ->
                      return '£' + y.toLocaleString()

$(document).ready ->
  if $('#funder_time').length
    Morris.Line({
      element: 'funder_time'
      data: [
        { y: '2013-06', a: 21, b: 55, c: 103 },
        { y: '2013-12', a: 14, b: 43, c: 106 },
        { y: '2014-07', a: 21, b: 43, c: 72 },
        { y: '2014-11', a: 13, b: 21, c: 34 }
      ],
      xkey: 'y'
      ymax: 110
      ykeys: ['a', 'b', 'c']
      labels: ['Min.', 'Avg.', 'Max.']
      xLabels: 'month'
      postUnits: ' weeks'
      lineColors: ['#ccc', '#F7BA0E', '#ccc']
      resize: true
      hideHover: 'auto'
      xLabelFormat: (x) ->
                      options =
                        year: '2-digit'
                        month: 'short'
                      x.toLocaleString 'en-gb', options
    });

  if $('#funder_stages').length
    Morris.Line({
      element: 'funder_stages'
      data: [
        { y: '2013-06', a: 52, b: 33, c: 12, d: 7 },
        { y: '2013-12', a: 50, b: 28, c: 12, d: 8 },
        { y: '2014-07', a: 44, b: 21, c: 8, d: 5 },
        { y: '2014-11', a: 45, b: 0, c: 5, d: 3 }
      ],
      xkey: 'y'
      ykeys: ['a', 'b', 'c', 'd']
      labels: ['Enquiries', 'Concept Notes', 'Applications', 'Grants' ]
      xLabels: 'month'
      lineColors: ['#ccc', '#bbb', '#aaa', '#F7BA0E']
      resize: true
      hideHover: 'auto'
      xLabelFormat: (x) ->
                      options =
                        year: '2-digit'
                        month: 'short'
                      x.toLocaleString 'en-gb', options
    });

  if $('#grants_size').length
    Morris.Line({
      element: 'grants_size'
      data: [
        { y: '2013-06', a: 34850, b: 47323, c: 75000 },
        { y: '2013-12', a: 21863, b: 35412, c: 46946 },
        { y: '2014-07', a: 28064, b: 38663, c: 45350 },
        { y: '2014-11', a: 26896, b: 30749, c: 33450 }
      ],
      xkey: 'y'
      ykeys: ['a', 'b', 'c']
      labels: ['Min.', 'Avg.', 'Max.']
      xLabels: 'month'
      preUnits: '£ '
      lineColors: ['#ccc', '#F7BA0E', '#ccc']
      resize: true
      hideHover: 'auto'
      xLabelFormat: (x) ->
                      options =
                        year: '2-digit'
                        month: 'short'
                      x.toLocaleString 'en-gb', options
    });

  if $('#grants_location').length
    Morris.Line
      element: "grants_location"
      data: [
        { y: '2013-06', a: 0, b: 2, c: 1, d: 4 },
        { y: '2013-12', a: 0, b: 1, c: 2, d: 5 },
        { y: '2014-07', a: 1, b: 1, c: 1, d: 2 },
        { y: '2014-11', a: 1, b: 1, c: 0, d: 1 }
      ]
      xkey: 'y'
      ymax: 6
      ykeys: ['a', 'b', 'c', 'd']
      labels: ['Ethiopia', 'Kenya', 'Uganda', 'United Kingdom']
      xLabels: 'month'
      postUnits: ' grants'
      lineColors: ['#ccc', '#aaa', '#666', '#F7BA0E']
      resize: true
      hideHover: 'auto'
      xLabelFormat: (x) ->
                      options =
                        year: '2-digit'
                        month: 'short'
                      x.toLocaleString 'en-gb', options

  if $('#recipient_age').length
    Morris.Line({
      element: 'recipient_age'
      data: [
        { y: '2013-06', a: 3, b: 11.7, c: 47.1 },
        { y: '2013-12', a: 1.4, b: 3.8, c: 8.4 },
        { y: '2014-07', a: 1, b: 2.7, c: 4.5 },
        { y: '2014-11', a: 1.1, b: 1.6, c: 2.1 }
      ],
      xkey: 'y'
      ykeys: ['a', 'b', 'c']
      labels: ['Min.', 'Avg.', 'Max.']
      xLabels: 'month'
      postUnits: ' years'
      lineColors: ['#ccc', '#F7BA0E', '#ccc']
      resize: true
      hideHover: 'auto'
      xLabelFormat: (x) ->
                      options =
                        year: '2-digit'
                        month: 'short'
                      x.toLocaleString 'en-gb', options
    });

  if $('#recipient_income').length
    Morris.Line({
      element: 'recipient_income'
      data: [
        { y: '2013-06', a: 53561, b: 403504.40, c: 1130797 },
        { y: '2013-12', a: 0, b: 90074.25, c: 249527 },
        { y: '2014-07', a: 40900, b: 63738.72, c: 120000 },
        { y: '2014-11', a: 10210.46, b: 22322.72, c: 34434.97 }
      ],
      xkey: 'y'
      ymax: 1200000
      ykeys: ['a', 'b', 'c']
      labels: ['Min.', 'Avg.', 'Max.']
      xLabels: 'month'
      preUnits: '£'
      lineColors: ['#ccc', '#F7BA0E', '#ccc']
      resize: true
      hideHover: 'auto'
      xLabelFormat: (x) ->
                      options =
                        year: '2-digit'
                        month: 'short'
                      x.toLocaleString 'en-gb', options
    });

  if $('#beneficiaries_age').length
    Morris.Area({
      element: 'beneficiaries_age'
      data: [
        { y: '2013-06', a: 14, b: 47 },
        { y: '2013-12', a: 14, b: 45 },
        { y: '2014-07', a: 13, b: 25 },
        { y: '2014-11', a: 12, b: 22 }
      ],
      xkey: 'y'
      ykeys: ['b', 'a']
      labels: ['Max.', 'Min.']
      xLabels: 'month'
      postUnits: ' years old'
      lineColors: ['#F7BA0E', '#ccc']
      resize: true
      hideHover: 'auto'
      behaveLikeLine: true
      xLabelFormat: (x) ->
                      options =
                        year: '2-digit'
                        month: 'short'
                      x.toLocaleString 'en-gb', options
    });

  if $('#beneficiaries_gender').length
    Morris.Area({
      element: 'beneficiaries_gender'
      data: [
        { y: '2013-06', a: 83, b: 17, c: 0, d: 0 },
        { y: '2013-12', a: 86, b: 14, c: 0, d: 0 },
        { y: '2014-07', a: 100, b: 0, c: 0, d: 0 },
        { y: '2014-11', a: 100, b: 0, c: 0, d: 0 }
      ],
      xkey: 'y'
      ykeys: ['a', 'b', 'c', 'd']
      labels: ['All genders', 'Only female', 'Only male', 'Only other genders']
      xLabels: 'month'
      postUnits: '%'
      lineColors: ['#F7BA0E', '#666', '#aaa', '#ccc']
      smooth: false
      resize: true
      hideHover: 'auto'
      xLabelFormat: (x) ->
                      options =
                        year: '2-digit'
                        month: 'short'
                      x.toLocaleString 'en-gb', options
    });

  if $('#beneficiaries_focus').length
    Morris.Bar({
      element: 'beneficiaries_focus'
      data: [
        { y: 'Disability', a: 50, b: 15 },
        { y: 'Physical Health', a: 33, b: 23 },
        { y: 'Mental Health', a: 17, b: 31 },
        { y: 'Education', a: 100, b: 54 },
        { y: 'Unemployment', a: 67, b: 92 },
        { y: 'Income Poverty', a: 83, b: 92 },
        { y: 'Ethnic Groups', a: 17, b: 23 },
        { y: 'Criminal Activities', a: 17, b: 31 },
        { y: 'Housing Issues', a: 17, b: 46 },
        { y: 'Family Issues', a: 33, b: 62 },
        { y: 'Other Organisations', a: 50, b: 54 }
      ],
      xkey: 'y'
      ykeys: ['a', 'b']
      labels: ['2014', '2013']
      postUnits: '%'
      barColors: ['#F7BA0E', '#ccc']
      resize: true
      hideHover: 'auto'
    });

  if $('#recipient_staff').length
    Morris.Line({
      element: 'recipient_staff'
      data: [
        { y: '2013-06', a: 1, b: 20, c: 63 },
        { y: '2013-12', a: 0, b: 6, c: 17 },
        { y: '2014-07', a: 2, b: 4, c: 6 },
        { y: '2014-11', a: 1, b: 4, c: 6 }
      ],
      xkey: 'y'
      ykeys: ['a', 'b', 'c']
      labels: ['Min.', 'Avg.', 'Max.']
      xLabels: 'month'
      postUnits: ' people'
      lineColors: ['#ccc', '#F7BA0E', '#ccc']
      resize: true
      hideHover: 'auto'
      xLabelFormat: (x) ->
                      options =
                        year: '2-digit'
                        month: 'short'
                      x.toLocaleString 'en-gb', options
    });

  if $('#recipient_volunteers').length
    Morris.Line({
      element: 'recipient_volunteers'
      data: [
        { y: '2013-06', a: 0, b: 71, c: 400 },
        { y: '2013-12', a: 0, b: 3, c: 6 },
        { y: '2014-07', a: 0, b: 2, c: 6 },
        { y: '2014-11', a: 3, b: 3, c: 4 }
      ],
      xkey: 'y'
      ykeys: ['a', 'b', 'c']
      labels: ['Min.', 'Avg.', 'Max.']
      xLabels: 'month'
      postUnits: ' people'
      lineColors: ['#ccc', '#F7BA0E', '#ccc']
      resize: true
      hideHover: 'auto'
      xLabelFormat: (x) ->
                      options =
                        year: '2-digit'
                        month: 'short'
                      x.toLocaleString 'en-gb', options
    });

  if $('#recipient_implement').length
    Morris.Bar({
      element: 'recipient_implement'
      data: [
        { y: 'Campaigns', a: 0, b: 15 },
        { y: 'Reasearch', a: 17, b: 23 },
        { y: 'Third Party', a: 17, b: 23 },
        { y: 'Products', a: 0, b: 8 },
        { y: 'Software', a: 33, b: 8 },
        { y: 'Beneficiaries', a: 33, b: 54 },
        { y: 'Voluneers', a: 50, b: 46 },
        { y: 'Staff', a: 67, b: 77 }
      ],
      xkey: 'y'
      ykeys: ['a', 'b']
      labels: ['2014', '2013']
      postUnits: '%'
      barColors: ['#F7BA0E', '#ccc']
      resize: true
      hideHover: 'auto'
    });

  if $('#recipient_goods_or_services').length
    Morris.Area({
      element: 'recipient_goods_or_services'
      data: [
        { y: '2013-06', a: 0, b: 67, c: 33 },
        { y: '2013-12', a: 0, b: 57, c: 43 },
        { y: '2014-07', a: 0, b: 100, c: 0 },
        { y: '2014-11', a: 0, b: 100, c: 0 }
      ],
      xkey: 'y'
      ykeys: ['a', 'b', 'c']
      labels: ['Products', 'Services', 'Both']
      xLabels: 'month'
      postUnits: '%'
      lineColors: ['#666', '#F7BA0E', '#aaa']
      smooth: false
      resize: true
      hideHover: 'auto'
      xLabelFormat: (x) ->
                      options =
                        year: '2-digit'
                        month: 'short'
                      x.toLocaleString 'en-gb', options
    });

  if $('#recipient_sells').length
    Morris.Area({
      element: 'recipient_sells'
      data: [
        { y: '2013-06', a: 0, b: 33, c: 17, d: 50 },
        { y: '2013-12', a: 14, b: 29, c: 14, d: 43},
        { y: '2014-07', a: 0, b: 25, c: 0, d: 75 },
        { y: '2014-11', a: 0, b: 50, c: 0, d: 50 }
      ],
      xkey: 'y'
      ykeys: ['a', 'b', 'c', 'd']
      labels: ['Products', 'Services', 'Both', 'None']
      xLabels: 'month'
      postUnits: '%'
      lineColors: ['#666', '#999', '#bbb', '#F7BA0E']
      smooth: false
      resize: true
      hideHover: 'auto'
      xLabelFormat: (x) ->
                      options =
                        year: '2-digit'
                        month: 'short'
                      x.toLocaleString 'en-gb', options
    });

OrganisationForm = ((w, d) ->

  triggerRegisteredToggle = (state)->
    target = $('.js-registered-toggle-target')
    if state == 'true'
      target.removeClass 'uk-hidden'
    else
      target.addClass 'uk-hidden'


  bindRegistrationToggle = ->
    selector = '.js-registered-toggle'
    elem     = $(selector)
    return unless elem.length > 0
    triggerRegisteredToggle(elem.val())
    $(document).on 'change', selector, ->
      triggerRegisteredToggle(elem.val())


  return { bindRegistrationToggle: bindRegistrationToggle }
)(window, document)



$(document).ready ->
  OrganisationForm.bindRegistrationToggle()

  createStoryJS
    type: "timeline"
    width: "100%"
    height: "400"
    source: $('#time_line').data('grants')
    embed_id: "time_line"
