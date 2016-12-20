# TODO: deprecated
class FundersController < ApplicationController
  before_action :ensure_funder, :load_funder
  before_action :load_district, only: :district

  respond_to :html

  def overview
    return if params[:id].present?
    @funder = current_user.organisation
    params[:id] = current_user.organisation.slug
  end

  def map
    gon.funderSlug = params[:id] == 'all' ? 'all' : @funder.slug
  end

  def map_data
    respond_to do |format|
      if params[:id] == 'all'
        @map_all_data = Rails.cache.fetch('map_all_data') do
          Funder.first.load_map_all_data
        end
        format.json { render json: @map_all_data }
      elsif @funder.current_attribute.map_data.present?
        # TODO: refactor check if map data updated?
        format.json { render json: @funder.current_attribute.map_data }
      else
        @funder.save_map_data
        format.json { render json: @funder.load_map_data }
      end
    end
  end

  def district
    ensure_own_district_path
    @amount_awarded = @funder.districts_by_year
                             .group(:district)
                             .sum(:amount_awarded)[@district.district]
    @grant_count = @funder.districts_by_year
                          .group(:district)
                          .count[@district.district]
  end

  private

    def load_funder
      @funder = Funder.find_by(slug: params[:id])
    end

    def load_district
      @district = District.find_by(slug: params[:district])
      gon.districtLabel = @district.district
      gon.funderName = @funder.name
    end

    def ensure_own_district_path
      return if current_user.organisation == @funder
      redirect_to funder_district_path(current_user.organisation,
                                       params[:district])
    end
end
