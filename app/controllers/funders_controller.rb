class FundersController < ApplicationController

  before_filter :ensure_logged_in
  before_filter :ensure_admin, only: [:comparison]
  before_filter :ensure_funder, only: [:recent, :map, :explore, :eligible, :map_data]
  before_filter :ensure_profile_for_current_year, only: [:show]
  before_filter :load_funder, except: [:new, :create]

  respond_to :html

  def show
    @recipient = current_user.organisation # refactor

    @restrictions = @funder.restrictions.uniq

    unless @recipient.is_subscribed? || @recipient.recommended_funder?(@funder)
      if current_user.feedbacks.count > 0
        redirect_to edit_feedback_path(current_user.feedbacks.last)
      else
        flash[:alert] = "Sorry, you don't have access to that"
        redirect_to recommended_funders_path
      end
    end
  end

  def recent
    @funder = Funder.find_by_name('Esmee Fairbairn Foundation') # refactor

    @recipients = @funder.recommended_recipients

    render 'funders/recipients/recent'
  end

  def map
    gon.funderSlug = @funder.slug

    # feat = []
    # Recipient.geocoded.each do |r|
    #   feat << { type: 'Feature', properties: { title: r.name, seeking: (r.proposals.count > 0 ? r.proposals.first.total_costs : ''), 'marker-color': '#afbc30', 'marker-size': 'medium', 'marker-symbol': 'star' }, geometry: { type: 'Point', coordinates: [r.longitude, r.latitude] } }
    # end
    # @geojson = { type: "FeatureCollection", features: feat }.to_json

    render 'funders/funding/map'
  end

  def map_data
    respond_to do |format|
      # refactor check if map data updated?
      if @funder.current_attribute.map_data.present?
        format.json { render json: @funder.current_attribute.map_data }
      else
        @funder.save_map_data
        format.json { render json: @funder.get_map_data }
      end
    end
  end

  def district
    @district = District.find_by_district(params[:district])

    render 'districts/show'
  end

  def explore
    @recipient = Recipient.find_by_slug(params[:id])
    @grants = @recipient.grants
    @funder = current_user.organisation
  end

  def eligible
    @eligible_organisations = @funder.eligible_organisations
  end

  def comparison
    @funders = Funder.where(name: ['The Foundation',
                    'The Dulverton Trust',
                    'Paul Hamlyn Foundation',
                    'The Indigo Trust',
                    'Nominet Trust']).to_a

    gon.funderName1 = @funders[0].name
    gon.funderName2 = @funders[1].name
    gon.funderName3 = @funders[2].name
    gon.funderName4 = @funders[3].name
    gon.funderName5 = @funders[4].name
  end

  private

  def load_funder
    @funder = Funder.find_by_slug(params[:id])
  end

end
