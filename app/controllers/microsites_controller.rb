class MicrositesController < ApplicationController
  layout 'microsite'

  before_action :load_funder, :load_attempt
  before_action :ensure_funder
  before_action only: %i[basics eligibility pre_results results] do
    start_path(@funder, @attempt)
  end

  def basics
    @microsite = Microsite.new(BasicsStep.new)
  end

  def check_basics
    @microsite = Microsite.new(BasicsStep.new(basics_params))
    if @microsite.save
      redirect_to microsite_eligibility_path @funder, @microsite.step.attempt
    else
      render :basics
    end
  end

  def eligibility # TODO: refactor
    # TODO: must be logged out OR avoid calls to ApplicationController

    @recipient = @attempt.recipient
    @recipient.valid?

    @microsite = Microsite.new(EligibilityStep.new(@recipient.attributes.slice(*recipient_attrs).merge(attempt: @attempt)))

    @recipient_answers = @microsite.step.answers_for('Recipient')
    @proposal_answers = @microsite.step.answers_for('Proposal')
  end

  def check_eligibility # TODO: refactor
    @recipient = @attempt.recipient
    @recipient.valid?

    @microsite = Microsite.new(EligibilityStep.new(@recipient.attributes.slice(*recipient_attrs).merge(attempt: @attempt).merge(eligibility_params)))
    @recipient_answers = @microsite.step.answers_for('Recipient')
    @proposal_answers = @microsite.step.answers_for('Proposal')

    if @microsite.save
      redirect_to microsite_pre_results_path(@funder, @attempt)
    else
      render :eligibility
    end
  end

  def pre_results
    @microsite = Microsite.new(PreResultsStep.new(attempt: @attempt))
  end

  def check_pre_results # TODO: refactor
    @microsite = Microsite.new(PreResultsStep.new({ attempt: @attempt }.merge(pre_results_params)))
    if @microsite.save
      MicrositeMailer.results(pre_results_params[:email], @funder, @attempt).deliver_now
      redirect_to microsite_results_path(@funder, @attempt, t: @attempt.access_token)
    else
      render :pre_results
    end
  end

  def results
    redirect_to microsite_basics_path(@funder) unless
      params[:t] == @attempt.access_token
    @proposal = @attempt.proposal
    @funds = @funder.funds.includes(:geo_area).active.order_by(@proposal, '')
  end

  private

    def load_funder
      @funder = Funder.find_by(slug: params[:slug])
    end

    def load_attempt
      @attempt = Attempt.find_by(id: params[:id], funder: @funder)
    end

    def basics_params
      params.require(:basics_step).permit(
        :funder_id, :funding_type, :total_costs, :org_type, :charity_number,
        :company_number, :country
      )
    end

    def eligibility_params
      params.require(:eligibility_step)
            .permit(*recipient_attrs, :affect_geo, country_ids: [], district_ids: [], answers: %w[eligible])
    end

    def pre_results_params
      params.require(:pre_results_step).permit(:email, :agree_to_terms)
    end

    def recipient_attrs
      %w[charity_number company_number name country street_address org_type
         income_band operating_for employees volunteers]
    end

    def ensure_funder
      redirect_to root_path unless @funder&.microsite
    end

    def should_redirect?(attempt)
      return false if params[:action] == 'basics'
      attempt&.state != params[:action]
    end

    def start_path(funder, attempt)
      return unless should_redirect?(attempt)
      action = attempt&.state || 'basics'
      redirect_to send("microsite_#{action}_path", funder, attempt)
    end
end
