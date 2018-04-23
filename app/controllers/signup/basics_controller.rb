module Signup
  class BasicsController < ApplicationController
    def new
      if logged_in?
        redirect_to funds_path(@proposal)
      else
        @form = Signup::Basics.new
        render 'pages/home'
      end
    end

    def create
      @form = Signup::Basics.new(form_params)

      if @form.valid?
        redirect_to signup_suitability_path(form_params)
      else
        render 'pages/home'
      end
    end

    private

      def form_params
        params.require(:signup_basics).permit(
          :charity_number, :company_number, :country, :funding_type,
          :org_type, themes: []
        ).reject { |_, v| v.blank? }
      end
  end
end
