class EligibilitiesController < ApplicationController

  before_filter :load_funder

  def new
    @eligibility = Eligibility.new
  end

  def create
    @eligibility = Eligibility.new(eligibility_params)
    if @eligibility.valid?
      redirect_to new_funder_enquiry_path(@funder)
    else
      render :new
    end
  end

  private

  def eligibility_params
    params.require(:eligibility).permit(:restriction1, :restriction2, :restriction3, :restriction4,
    :restriction5, :restriction6, :restriction7, :restriction8, :restriction9, :restriction10)
  end

  def load_funder
    @funder = Funder.find_by_slug(params[:funder_id])
  end

end
