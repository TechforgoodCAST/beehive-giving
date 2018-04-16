module Signup
  class SuitabilityController < ApplicationController
    include Mixpanelable

    layout 'fullscreen'

    before_action :load_basics

    def new
      return redirect_to funds_path(@proposal) if logged_in?
      return redirect_to root_path unless @basics.valid?
      @form = Signup::Suitability.new(@basics)
    end

    def create
      @form = Signup::Suitability.new(@basics, form_params)

      return redirect_to unauthorised_path if @form.recipient_registered

      if @form.save
        cookies[:auth_token] = @form.user.auth_token
        mixpanel_identify(@form.user, request)
        @form.proposal.next_step! # TODO: refactor
        Assessment.analyse_and_update!(Fund.active, @form.proposal)
        redirect_to funds_path(@form.proposal)
      else
        render :new
      end
    end

    private

      def basics_params
        params.permit(
          :charity_number, :company_number, :country, :funding_type,
          :org_type, themes: []
        )
      end

      def form_params
        params.require(:signup_suitability).permit(
          recipient: [
            :charity_number, :company_number, :employees, :income_band, :name,
            :operating_for, :org_type, :street_address, :volunteers, :website
          ],
          proposal: [
            :affect_geo, :all_funding_required, :funding_duration, :private,
            :tagline, :title, :total_costs, district_ids: [], country_ids: []
          ],
          user: [
            :agree_to_terms, :email, :first_name, :last_name, :password
          ]
        )
      end

      def load_basics
        @basics = Signup::Basics.new(basics_params)
      end
  end
end
