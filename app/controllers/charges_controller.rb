class ChargesController < ApplicationController
  before_action :ensure_logged_in, :authenticate, :init_payment

  def new
    session[:return_to] = request.referer
    @notice = true if request.referer == account_subscription_url(@recipient)
  end

  def create
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

  private

    def authenticate
      authorize :charge
    end

    def init_payment
      @payment = Payment.new(@recipient)
    end

    def user_not_authorised
      redirect_to(
        session.delete(:return_to) || account_subscription_path(@recipient)
      )
    end
end
