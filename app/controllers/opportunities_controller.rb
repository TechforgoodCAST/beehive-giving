class OpportunitiesController < ApplicationController
  before_action :load_collection, only: :show

  def index
    @opportunities = Funder.where(active: true) + Theme.all
    @opportunities.sort_by!(&:name)
  end

  def show
    @reports = @collection.proposals.includes(:collection, :recipient)
                          .order(created_at: :desc)
  end
end
