$(document).ready ->
  i = 0
  while i < 6
    if $('#funding-size-' + i).length
      Morris.Bar
        element: 'funding-size-' + i
        data: $('#funding-size-' + i).data('data')
        xkey: 'target'
        ykeys: ['grant_count']
        labels: ['No. of Grants']
        barColors: ['#F7BA0E']
        resize: true
        hideHover: 'auto'
        gridTextSize: 10
    i++
