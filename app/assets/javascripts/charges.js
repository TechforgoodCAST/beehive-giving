(function() {

  function stripeResponseHandler(status, response) {
    var $form = $('#payment-form');
    if (response.error) {
      $form.find('.payment-errors').text(response.error.message).addClass('cta red');
      $form.find('.submit').prop('disabled', false).html('Pay securely');
    } else {
      $('#stripeToken').val(response.id);
      $form.get(0).submit();
    }
  };

  function getCardLogo() {
    $('#card-number').on('blur', function(e) {
      var cardType = Stripe.cardType($('#card-number').val())
                           .toLowerCase()
                           .replace(" ", "-");
      $('.payment-card').attr('class', 'payment-card ' + cardType);
    });
  }

  $(function() {
    getCardLogo();
    var $form = $('#payment-form');
    $form.submit(function(event) {
      $form.find('.submit').prop('disabled', true)
           .html("<i class='uk-icon uk-icon-circle-o-notch uk-icon-spin'></i>")
      Stripe.card.createToken($form, stripeResponseHandler);
      return false;
    });
  });

})();
