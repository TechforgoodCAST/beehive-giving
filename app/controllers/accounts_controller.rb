class AccountsController < ApplicationController

  before_filter :ensure_logged_in, :load_recipient, :ensure_proposal_present

  def user; end

  def organisation; end

  def subscription
    @subscription = @recipient.subscription
    if @subscription.active?
      stripe_customer = Stripe::Customer.retrieve(@subscription.stripe_user_id)
      stripe_subscription = stripe_customer.subscriptions.first
      expiry_date = Time.at(stripe_subscription[:current_period_end]).to_date
      @expiry = expiry_date.strftime("#{expiry_date.day.ordinalize} %B %Y")
    end
  end

  def upgrade
    redirect_to account_subscription_path(@recipient), alert: "You're already subscribed!" if @recipient.subscribed?
  end

  def charge
    unless @recipient.subscribed?
      create_stripe_customer
      redirect_to account_subscription_path(@recipient)
    end
  end

  private

    def create_stripe_customer
      customer = Stripe::Customer.create(
        source: params[:stripeToken],
        plan: 'pro-annual',
        email: current_user.user_email,
        description: "#{current_user.full_name}, #{@recipient.slug}"
      )
      @recipient.update!(
        stripe_user_id: customer.id,
        active: true
      )
    end

end
