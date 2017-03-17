class ChargesController < ApplicationController
  before_action :ensure_logged_in
  before_action :init_payment

  def new
    return unless @recipient.subscribed?
    redirect_to account_subscription_path(@recipient),
                alert: "You're already subscribed!"
  end

  def create
    return if @recipient.subscribed?
    if valid_coupon?
      @payment.create_stripe_customer!(
        params[:stripeToken], current_user, params[:coupon]
      )
      redirect_to account_subscription_path(@recipient)
    else
      params[:coupon_errors] = 'Invalid coupon'
      render :new
    end
  end

  private

    def init_payment
      @payment = Payment.new(@recipient)
    end

    def valid_coupon?
      return true if params[:coupon].blank?
      Stripe::Coupon.all.pluck(:id).include?(params[:coupon])
    end
end
