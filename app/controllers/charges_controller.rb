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
    if @payment.process!(params[:stripeToken], current_user, params[:coupon])
      redirect_to account_subscription_path(@recipient), notice: 'Subscribed!'
    else
      params[:card_errors] = 'Invalid coupon'
      render :new
    end
  rescue Stripe::CardError => e
    params[:card_errors] = e.message
    render :new
  end

  private

    def init_payment
      @payment = Payment.new(@recipient)
    end
end
