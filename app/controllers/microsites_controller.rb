class MicrositesController < ApplicationController
  before_action :load_funder

  def basics
    @microsite = Microsite.new(BasicsStep.new)
  end

  def check_basics
    @microsite = Microsite.new(BasicsStep.new(basics_params))
    if @microsite.save
      redirect_to microsite_eligibility_path
    else
      render :basics
    end
  end

  def eligibility
    @recipient = Recipient.find_by(id: params[:recipient_id])
    redirect_to microsite_basics_path unless @recipient
    # TODO: redirect_to microsite_suitability_path(@recipient) if
    #   @recipient.suitability?
    @restrictions = @funder.restrictions
  end

  def check_eligibility; end

  private

    def load_funder
      @funder = Funder.find_by(slug: params[:slug])
    end

    def basics_params
      params.require(:basics_step)
            .permit(:funding_type, :total_costs, :org_type)
    end
end
