document.addEventListener('turbolinks:load', () => {
  (function (w, d, id) {
    const FORM = d.getElementById(id)

    function init () {
      FORM.addEventListener('submit', processForm, false)
    }

    function processForm (e) {
      e.preventDefault()

      const requiredFields = {
        number: d.getElementById('card-number').value,
        cvc: d.getElementById('cvc').value,
        exp_month: d.getElementById('expiry-month').value,
        exp_year: d.getElementById('expiry-year').value
      }

      Stripe.card.createToken(requiredFields, stripeResponseHandler)
    }

    function stripeResponseHandler (status, response) {
      const btn = d.querySelector('button[type="submit"')
      const msg = d.querySelector('.payment-errors')

      if (response.error) {
        btn.disabled = false
        btn.classList.remove('disabled')
        msg.classList.remove('hide')
        msg.textContent = response.error.message
      } else {
        btn.disabled = true
        btn.classList.add('disabled')
        msg.classList.add('hide')
        d.getElementById('stripeToken').value = response.id
        FORM.submit()
      }
    }

    return (FORM ? init() : null)
  }(window, document, 'payment-form'))
}, false)
