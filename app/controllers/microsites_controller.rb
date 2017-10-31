class MicrositesController < ApplicationController
  before_action :load_funder, :load_assessment
  before_action :ensure_funder
  before_action only: %i[basics eligibility pre_results results] do
    start_path(@funder, @assessment)
  end

  def basics
    @microsite = Microsite.new(BasicsStep.new)
  end

  def check_basics
    @microsite = Microsite.new(BasicsStep.new(basics_params))
    if @microsite.save
      redirect_to microsite_eligibility_path @funder, @microsite.step.assessment
    else
      render :basics
    end
  end

  def eligibility # TODO: refactor
    # TODO: must be logged out OR avoid calls to ApplicationController

    @recipient = @assessment.recipient
    @recipient.valid?

    @microsite = Microsite.new(EligibilityStep.new(@recipient.attributes.slice(*recipient_attrs).merge(assessment: @assessment)))

    @recipient_answers = @microsite.step.answers_for('Recipient')
    @proposal_answers = @microsite.step.answers_for('Proposal')
  end

  def check_eligibility # TODO: refactor
    @recipient = @assessment.recipient
    @recipient.valid?

    @microsite = Microsite.new(EligibilityStep.new(@recipient.attributes.slice(*recipient_attrs).merge(assessment: @assessment).merge(eligibility_params)))
    @recipient_answers = @microsite.step.answers_for('Recipient')
    @proposal_answers = @microsite.step.answers_for('Proposal')

    if @microsite.save
      redirect_to microsite_pre_results_path @funder, @microsite.step.assessment
    else
      render :eligibility
    end
  end

  def pre_results
    @microsite = Microsite.new(PreResultsStep.new(assessment: @assessment))
  end

  def check_pre_results # TODO: refactor
    @microsite = Microsite.new(PreResultsStep.new({ assessment: @assessment }.merge(pre_results_params)))
    if @microsite.save
      redirect_to microsite_results_path @funder, @assessment
    else
      render :pre_results
    end
  end

  def results; end

  private

    def load_funder
      @funder = Funder.find_by slug: params[:slug]
    end

    def load_assessment
      @assessment = Assessment.find_by id: params[:id], funder: @funder
    end

    def basics_params
      params.require(:basics_step).permit(
        :funder_id, :funding_type, :total_costs, :org_type, :charity_number,
        :company_number
      )
    end

    def eligibility_params
      params.require(:eligibility_step)
            .permit(*recipient_attrs, answers: %w[eligible])
    end

    def pre_results_params
      params.require(:pre_results_step).permit(:email)
    end

    def recipient_attrs
      %w[charity_number company_number name country street_address org_type
         income_band operating_for employees volunteers]
    end

    def ensure_funder
      redirect_to root_path unless @funder
    end

    def should_redirect?(assessment)
      return false if params[:action] == 'basics'
      assessment&.state != params[:action]
    end

    def start_path(funder, assessment)
      return unless should_redirect?(assessment)
      action = assessment&.state || 'basics'
      redirect_to send("microsite_#{action}_path", funder, assessment)
    end
end
