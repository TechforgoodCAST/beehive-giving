class OpportunitiesController < ApplicationController
  def index
    @opportunities = Funder.where(active: true) + Theme.all
    @opportunities.sort_by!(&:name)
  end
end
