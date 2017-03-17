function stripeResponseHandler(status, response) {
  var $form = $('#payment-form');
  if (response.error) {
    $form.find('.payment-errors').text(response.error.message).addClass('cta red');
    $form.find('.submit').prop('disabled', false);
  } else {
    $('#stripeToken').val(response.id);
    $form.get(0).submit();
  }
};

$(function() {
  var $form = $('#payment-form');
  $form.submit(function(event) {
    $form.find('.submit').prop('disabled', true);
    Stripe.card.createToken($form, stripeResponseHandler);
    return false;
  });
});
