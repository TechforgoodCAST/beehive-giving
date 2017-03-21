class AccountsController < ApplicationController
  before_action :ensure_logged_in

  def subscription
    @subscription = @recipient.subscription
    @payment = Payment.new(@recipient)
  end
end
