class SubscriptionsHelper

  include Capybara::DSL

  def create_stripe_plan(stripe)
    stripe.create_plan(
      id: 'pro-annual',
      name: 'Pro - Annual',
      amount: 4800,
      currency: 'gbp',
      interval: 'year'
    )
    self
  end

  def pay_by_card(stripe)
    create_stripe_plan(stripe)
    fill_in 'card-number', with: '4242 4242 4242 4242'
    fill_in 'expiry-month', with: '01'
    fill_in 'expiry-year', with: Date.today.year + 1
    fill_in 'cvc', with: '123'
    find("#stripeToken", visible: false).set stripe.generate_card_token
    click_on 'Pay securely'
    self
  end

end
