class Payment
  def initialize(organisation)
    @recipient = organisation
    @subscription = organisation.subscription
  end

  def subscription_expiry # TODO: store on Subscription and remove
    return nil unless @subscription.active?
    expiry_date = Time.zone.at(
      stripe_customer.subscriptions.first[:current_period_end]
    ).to_date
    expiry_date.strftime("#{expiry_date.day.ordinalize} %B %Y")
  end

  def plan_cost
    Subscription::PLANS.values[@recipient.income] / 100
  end

  def process!(token, user, coupon)
    return false unless valid_coupon?(coupon)
    customer = create_stripe_customer(token, user)
    create_stripe_subscription(customer.id, coupon)
    update_subscription(customer.id)
  end

  private

    def valid_coupon?(coupon)
      return true if coupon.blank?
      Stripe::Coupon.all.pluck(:id).include?(coupon)
    end

    def plan_id
      Subscription::PLANS.keys[@recipient.income].to_s.parameterize
    end

    def stripe_customer
      return nil unless @subscription.active?
      Stripe::Customer.retrieve(@subscription.stripe_user_id)
    end

    def create_stripe_customer(token, user)
      Stripe::Customer.create source: token,
                              email: user.email,
                              description: user.full_name + ', ' +
                                           @recipient.slug
    end

    def create_stripe_subscription(customer_id, coupon)
      Stripe::Subscription.create customer: customer_id,
                                  plan: plan_id,
                                  coupon: coupon.blank? ? nil : coupon
    end

    def update_subscription(customer_id)
      @subscription.update! stripe_user_id: customer_id, active: true
      # TODO: store expiry_date
      # TODO: store discounts applied
    end
end
