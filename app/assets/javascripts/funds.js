$(document).ready(function() {

  if ($('#funding_frequency_distribution').length) {
    Morris.Bar({
      element: 'funding_frequency_distribution',
      data: $('#funding_frequency_distribution').data('data'),
      xkey: 'segment',
      ykeys: ['count'],
      labels: ['No. of grants'],
      barColors: ['#F7BA0E'],
      resize: true,
      hideHover: 'auto'
    });
  }

  if ($('#funding_by_month').length) {
    var fundingByMonth = Morris.Bar({
      element: 'funding_by_month',
      data: $('#funding_by_month').data('data'),
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
