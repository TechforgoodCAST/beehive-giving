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
      smooth: false
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
      smooth: false
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

$(document).ready ->
  if $('#grants_size').length
    Morris.Line
      element: 'grants_size'
      data: $('#grants_size').data('grants')
      xkey: 'approved_on'
      ykeys: ['average', 'minimum', 'maximum']
      labels: ['Amount awarded']
      smooth: false
      resize: true
      hideHover: 'auto'
      lineColors: ['#F7BA0E', '#bbb', '#bbb']
      dateFormat: (x) ->
                      indexToMonth = ['Jan', 'Feb','Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'] # refactor?
                      month = indexToMonth[new Date(x).getMonth()]
                      year = new Date(x).getFullYear()
                      return month + ' ' + year
      hoverCallback: (index, options, content, row) ->
                      return '<div class="morris-hover-row-label">' + 'Funding given in ' + options.dateFormat(row.approved_on) + '</div><div>Funding size</div><span>Max: </span><b style="color: ' + options.lineColors[2] + '">' + '£' + row.maximum.toLocaleString() + ' </b></br><span>Avg: </span><b style="color: ' + options.lineColors[0] + '">' + '£' + row.average.toLocaleString() + ' </b></br><span>Min: </span><b style="color: ' + options.lineColors[1] + '">' + '£' + row.minimum.toLocaleString() + ' </b></br><span>No. of awards: </span>' + row.count
      xLabelFormat: (x) ->
                      return x.toLocaleString('en-gb', { year: 'numeric', month: 'short' })
      yLabelFormat: (y) ->
                      return '£' + y.toLocaleString()

$(document).ready ->
  if $('#grants_duration').length
    Morris.Line
      element: 'grants_duration'
      data: $('#grants_duration').data('grants')
      xkey: 'approved_on'
      ykeys: ['maximum', 'average', 'minimum']
      labels: ['Max', 'Avg', 'Min']
      smooth: false
      resize: true
      hideHover: 'auto'
      postUnits: ' months'
      lineColors: ['#bbb', '#F7BA0E', '#bbb']
      dateFormat: (x) ->
                      indexToMonth = ['Jan', 'Feb','Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'] # refactor?
                      month = indexToMonth[new Date(x).getMonth()]
                      year = new Date(x).getFullYear()
                      return month + ' ' + year
      xLabelFormat: (x) ->
                      return x.toLocaleString('en-gb', { year: 'numeric', month: 'short' })

$(document).ready ->
  if $('#success_rate').length
    Morris.Bar
      element: 'success_rate'
      data: $('#success_rate').data('grants')
      xkey: 'year'
      ykeys: ['grant_count', 'application_count', 'enquiry_count']
      labels: ['Grants', 'Applications', 'Enquiries']
      barColors: ['#F7BA0E', '#777', '#bbb']
      resize: true
      hideHover: 'auto'

$(document).ready ->
  if $('#recipient_age').length
    Morris.Line
      element: 'recipient_age'
      data: $('#recipient_age').data('grants')
      xkey: 'approved_on'
      ykeys: ['max', 'avg', 'min']
      labels: ['Max', 'Avg', 'Min']
      xLabels: 'month'
      postUnits: ' years'
      lineColors: ['#bbb', '#F7BA0E', '#bbb']
      resize: true
      smooth: false
      hideHover: 'auto'
      goals: [age]
      goalLineColors: ['#00a8e6']
      dateFormat: (x) ->
                      indexToMonth = ['Jan', 'Feb','Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'] # refactor?
                      month = indexToMonth[new Date(x).getMonth()]
                      year = new Date(x).getFullYear()
                      return month + ' ' + year
      xLabelFormat: (x) ->
                      return x.toLocaleString('en-gb', { year: 'numeric', month: 'short' })

$(document).ready ->
  if $('#recipient_income').length
    Morris.Line
      element: 'recipient_income'
      data: $('#recipient_income').data('grants')
      xkey: 'approved_on'
      ykeys: ['max', 'avg', 'min']
      labels: ['Max', 'Avg', 'Min']
      xLabels: 'month'
      preUnits: '£'
      lineColors: ['#bbb', '#F7BA0E', '#bbb']
      resize: true
      smooth: false
      hideHover: 'auto'
      goals: [income]
      goalLineColors: ['#00a8e6']
      dateFormat: (x) ->
                      indexToMonth = ['Jan', 'Feb','Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'] # refactor?
                      month = indexToMonth[new Date(x).getMonth()]
                      year = new Date(x).getFullYear()
                      return month + ' ' + year
      xLabelFormat: (x) ->
                      return x.toLocaleString('en-gb', { year: 'numeric', month: 'short' })

$(document).ready ->
  if $('#compare_funder').length
    Morris.Line
      element: 'compare_funder'
      data: $('#compare_funder').data('grants')
      xkey: 'approved_on'
      ykeys: ['funder1', 'funder2']
      labels: [funderName1, funderName2]
      smooth: false
      resize: true
      postUnits: ' grants'
      lineColors: ['#F7BA0E', '#bbb', '#bbb']
      dateFormat: (x) ->
                      indexToMonth = ['Jan', 'Feb','Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'] # refactor?
                      month = indexToMonth[new Date(x).getMonth()]
                      year = new Date(x).getFullYear()
                      return month + ' ' + year
      # hoverCallback: (index, options, content, row) ->
      #                 return '<div class="morris-hover-row-label">' + options.dateFormat(row.approved_on) + '</div><div>No. of grants</div><span>' + options.labels[0] + ': </span><b style="color: ' + options.lineColors[0] + '">' + row.funder1 + ' grants</b></br><span>' + options.labels[1] + ': </span><b style="color: ' + options.lineColors[1] + '">' + row.funder2 + ' grants</b>'
      xLabelFormat: (x) ->
                      return x.toLocaleString('en-gb', { year: 'numeric', month: 'short' })

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
