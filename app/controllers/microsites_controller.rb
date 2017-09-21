class MicrositesController < ApplicationController
  before_action :load_funder, :load_assessment
  before_action :ensure_funder
  before_action only: %i[basics eligibility] do
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

  def eligibility
    @recipient = @assessment.recipient
    @restrictions = @funder.restrictions
  end

  def check_eligibility; end

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

    def ensure_funder
      redirect_to root_path unless @funder
    end

    def should_redirect?(assessment)
      return false if params[:action] == 'basics'
      assessment&.state != params[:action]
    end

    def start_path(funder, assessment)
      return unless should_redirect? assessment
      case assessment&.state
      when 'eligibility'
        redirect_to microsite_eligibility_path funder, assessment
      when 'suitability'
        redirect_to microsite_suitability_path funder, assessment
      else
        redirect_to microsite_basics_path
      end
    end
end
