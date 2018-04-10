module Signup
  class SuitabilityController < ApplicationController
    layout 'fullscreen'

    before_action :load_basics

    def new
      redirect_to signup_basics_path unless @basics.valid?
      @count = Fund.filter_sort(nil, params).active.size # TODO: refactor
      @form = Signup::Suitability.new(@basics)
    end

    def create
      @form = Signup::Suitability.new(@basics, form_params)

      if @form.save
        raise 'Success!'
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
            :affect_geo, :funding_duration, :private, :tagline, :title,
            :total_costs, district_ids: [], country_ids: []
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
