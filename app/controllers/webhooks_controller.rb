class WebhooksController < ApplicationController
  protect_from_forgery except: :webhook
  before_action :load_customer

  def invoice_payment_succeeded
    Stripe::Subscription.retrieve(@customer.subscriptions.first.id)
                        .delete(at_period_end: true)
  rescue NoMethodError
    nil
  end

  def customer_subscription_deleted
    Subscription.find_by(stripe_user_id: @customer.id)
                .update(active: false, percent_off: 0)
  rescue NoMethodError
    nil
  end

  def subscription_expired
    # TODO: deactivate Beehive::Subscription at_period_end
    # TODO: send reminder emails
  end

  private

    def load_customer
      @customer = Stripe::Customer.retrieve(params[:data][:object][:customer])
    end
end
