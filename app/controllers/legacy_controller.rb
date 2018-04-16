class LegacyController < ApplicationController
  before_action :legacy_funder, :legacy_fundraiser

  def fundraiser_reset
    # TODO: pending
  end

  private

    def legacy_funder; end

    def legacy_fundraiser; end
end
