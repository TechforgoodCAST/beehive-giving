class OpportunitiesController < ApplicationController
  before_action :load_collection, only: :show

  def index
    funders = Funder.where(active: true)
    themes = Theme.joins(:funds).where('funds.state': 'active').distinct
    @opportunities = funders + themes
    @opportunities.sort_by!(&:name)
  end

  def show
    @reports = @collection.proposals.includes(:collection, :recipient)
                          .order(created_at: :desc)
  end
end
