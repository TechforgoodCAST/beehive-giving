class Payment
  def initialize(organisation)
    @recipient = organisation
    @subscription = organisation.subscription
  end

  def plan_cost
    cost = Subscription.plans.values[@recipient.income_band] / 100
    return cost unless @subscription
    cost - (cost * (@subscription.percent_off.to_f / 100))
  end

  def discount
    return false unless @subscription.percent_off.positive?
    ActiveSupport::NumberHelper
      .number_to_percentage(@subscription.percent_off, precision: 0)
  end

  def process!(token, user, coupon)
    return false unless valid_coupon?(coupon)
    customer = create_stripe_customer(token, user)
    create_stripe_subscription(customer, coupon)
    update_subscription(customer, coupon)
  end

  private

    def valid_coupon?(coupon)
      return true if coupon.blank?
      Stripe::Coupon.all.pluck(:id).include?(coupon)
    end

    def plan_id
      Subscription.plans.keys[@recipient.income_band].to_s.parameterize
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

    def create_stripe_subscription(customer, coupon)
      Stripe::Subscription.create customer: customer.id,
                                  plan: plan_id,
                                  coupon: coupon.blank? ? nil : coupon
    end

    def percent_off(coupon)
      Stripe::Coupon.retrieve(coupon).percent_off
    rescue Stripe::InvalidRequestError
      0
    end

    def update_subscription(customer, coupon)
      @subscription.update! stripe_user_id: customer.id,
                            active: true,
                            expiry_date: 1.year.from_now.to_date,
                            percent_off: percent_off(coupon)
    end
end
