$(document).on('turbolinks:load', function () {
  let $amountAwarded = $('#amount_awarded_distribution')
  if ($amountAwarded.length && $amountAwarded.empty()) {
    window.Morris.Bar({
      element: 'amount_awarded_distribution',
      data: $amountAwarded.data('data'),
      xkey: 'segment',
      ykeys: ['count'],
      labels: ['No. of grants'],
      barColors: ['#F7BA0E'],
      resize: true,
      hideHover: 'auto'
    })
  }

  let $awardMonth = $('#award_month_distribution')
  if ($awardMonth.length && $awardMonth.empty()) {
    window.Morris.Bar({
      element: 'award_month_distribution',
      data: $awardMonth.data('data'),
      xkey: 'month',
      ykeys: ['count'],
      postUnits: ' grants',
      labels: ['Awarded'],
      barColors: ['#F7BA0E'],
      resize: true,
      hideHover: 'auto'
    })
  }
})
