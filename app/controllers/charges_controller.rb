class ChargesController < ApplicationController
  before_action :ensure_logged_in, :init_payment

  def new
    session[:return_to] = request.referer
    @notice = true if request.referer == account_subscription_url(@recipient)
    return unless @recipient.subscribed?
    redirect_to account_subscription_path(@recipient),
                alert: "You're already subscribed!"
  end

  def create
    return if @recipient.subscribed?
    if @payment.process!(params[:stripeToken], current_user, params[:coupon])
      redirect_to thank_you_path(@recipient)
    else
      params[:card_errors] = 'Invalid coupon'
      render :new
    end
  rescue Stripe::CardError => e
    params[:card_errors] = e.message
    render :new
  end

  def thank_you
    return if @recipient.subscribed?
    redirect_to account_subscription_path(@recipient),
                alert: 'Please upgrade your subscription'
  end

  private

    def init_payment
      @payment = Payment.new(@recipient)
    end
end
