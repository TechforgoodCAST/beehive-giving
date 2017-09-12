class SubscriptionsHelper
  include Capybara::DSL

  def pay_by_card(stripe, coupon: nil)
    create_stripe_plans(stripe)
    create_stripe_coupons(stripe)
    fill_in 'card-number', with: '4242 4242 4242 4242'
    fill_in 'expiry-month', with: '01'
    fill_in 'expiry-year', with: Time.zone.today.year + 1
    fill_in 'cvc', with: '123'
    fill_in 'coupon', with: coupon if coupon
    find('#stripeToken', visible: false).set stripe.generate_card_token
    click_on 'Pay securely'
    self
  end

  def stripe_customer(recipient)
    Stripe::Customer.retrieve(recipient.subscription.stripe_user_id)
  end

  def stripe_subscription(recipient)
    customer = stripe_customer(recipient)
    Stripe::Subscription.retrieve(customer.subscriptions.first.id)
  end

  private

    def create_stripe_plans(stripe)
      Subscription.plans.each do |plan, amount|
        stripe.create_plan(
          id: plan.to_s.parameterize,
          name: plan.to_s,
          amount: amount,
          currency: 'gbp',
          interval: 'year'
        )
      end
    end

    def create_stripe_coupons(stripe)
      {
        test10: 10,
        test20: 20
      }.each do |coupon, percent|
        stripe.create_coupon(
          id: coupon.to_s,
          percent_off: percent,
          amount_off: nil,
          max_redemptions: nil
        )
      end
    end
end
