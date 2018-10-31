class ChargesController < ApplicationController
  layout 'fullscreen' # TODO: refactor

  before_action :build_order, :load_proposal, :authenticate
  before_action :build_payment, only: :create

  def create
    if @payment.process!(@proposal.user, params[:stripeToken])
      @proposal.update_column(:private, Time.zone.now)
      redirect_to report_path(@proposal, t: @proposal.access_token)
    else
      render :new
    end
  rescue Stripe::CardError => e
    params[:card_errors] = e.message
    render :new
  end

  private

    def authenticate
      authorize @proposal, policy_class: ChargePolicy
    end

    def build_order
      @order = Order.new(
        ENV['STRIPE_AMOUNT_OPPORTUNITY_SEEKER'],
        ENV['STRIPE_FEE_OPPORTUNITY_SEEKER']
      )
    end

    def build_payment
      @payment = Payment.new(
        amount: @order.total,
        description: "Made report ##{@proposal.id} private."
      )
    end

    def load_proposal
      @proposal = Proposal.find_by(id: params[:proposal_id])
    end

    def user_not_authorised
      if @proposal
        redirect_to report_path(@proposal)
      else
        render 'errors/not_found', status: 404
      end
    end
end
