# TODO: deprecated
class FundersController < ApplicationController
  before_action :ensure_funder, :load_funder
  before_action :load_district, only: :district

  respond_to :html

  def overview
    return if params[:id].present?
    @funder = current_user.organisation
    params[:id] = @funder.slug
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
                             .group(:name)
                             .sum(:amount_awarded)[@district.name]
    @grant_count = @funder.districts_by_year
                          .group(:name)
                          .count[@district.name]
  end

  private

    def ensure_funder
      return if logged_in? && funder?
      redirect_to sign_in_path, alert: "Sorry, you don't have access to that"
    end

    def load_funder
      @funder = Funder.find_by(slug: params[:id])
    end

    def load_district
      @district = District.find_by(slug: params[:name])
      gon.districtLabel = @district.name
      gon.funderName = @funder.name
    end

    def ensure_own_district_path
      return if current_user.organisation == @funder
      redirect_to funder_district_path(current_user.organisation,
                                       params[:name])
    end
end
