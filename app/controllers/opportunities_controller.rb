class OpportunitiesController < ApplicationController
  before_action :load_collection, only: :show

  def index
    funders = Funder.where(active: true)
    themes = Theme.joins(:funds).where('funds.state': 'active').distinct
    array = (funders + themes).sort_by!(&:name)
    @opportunities = Kaminari.paginate_array(array).page(params[:page]).per(20)
  end

  def show
    @reports = @collection.proposals.includes(:recipient)
                          .order(created_at: :desc)
                          .page(params[:page])

    @breakdown = @collection.assessments.group(:suitability_status).count
  end
end
