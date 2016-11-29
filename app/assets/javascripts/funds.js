$(document).ready(function() {

  if ($('#amount_awarded_distribution').length) {
    Morris.Bar({
      element: 'amount_awarded_distribution',
      data: $('#amount_awarded_distribution').data('data'),
      xkey: 'segment',
      ykeys: ['count'],
      labels: ['No. of grants'],
      barColors: ['#F7BA0E'],
      resize: true,
      hideHover: 'auto'
    });
  }

  if ($('#award_month_distribution').length) {
    var fundingByMonth = Morris.Bar({
      element: 'award_month_distribution',
      data: $('#award_month_distribution').data('data'),
      xkey: 'month',
      ykeys: ['count'],
      postUnits: ' grants',
      labels: ['Awarded'],
      barColors: ['#F7BA0E'],
      resize: true,
      hideHover: 'auto'
    });
  }

});
