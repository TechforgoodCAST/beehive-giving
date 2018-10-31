class Payment
  def initialize(args = {})
    @amount = args[:amount]
    @description = args[:description]
    raise 'amount required' if @amount.nil?
  end

  def process!(user, token)
    if user.stripe_user_id
      customer = Stripe::Customer.retrieve(user.stripe_user_id)
    else
      customer = Stripe::Customer.create(email: user.email, source: token)
      user.try(:update_column, :stripe_user_id, customer.id)
    end

    charge!(customer)
  end

  private

    def charge!(customer)
      Stripe::Charge.create(
        amount: @amount,
        currency: 'gbp',
        description: @description,
        customer: customer.id
      )
    end
end
