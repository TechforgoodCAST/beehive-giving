class Payment
  def initialize(organisation)
    @recipient = organisation
    @subscription = organisation.subscription
  end

  def stripe_customer
    return nil unless @subscription.active?
    Stripe::Customer.retrieve(@subscription.stripe_user_id)
  end

  def subscription_expiry
    return nil unless @subscription.active?
    expiry_date = Time.zone.at(
      stripe_customer.subscriptions.first[:current_period_end]
    ).to_date
    expiry_date.strftime("#{expiry_date.day.ordinalize} %B %Y")
  end

  def plan_id
    Subscription::PLANS.keys[@recipient.income].to_s.parameterize
  end

  def plan_name
    Subscription::PLANS.keys[@recipient.income]
  end

  def plan_cost
    Subscription::PLANS.values[@recipient.income] / 100
  end

  def create_stripe_customer!(token, user, coupon)
    customer = Stripe::Customer.create(
      source: token,
      plan: plan_id,
      email: user.email,
      description: "#{user.full_name}, #{@recipient.slug}",
      coupon: coupon.blank? ? nil : coupon
    )
    @subscription.update!(
      stripe_user_id: customer.id, active: true
    )
  end
end
