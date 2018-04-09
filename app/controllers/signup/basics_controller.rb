module Signup
  class BasicsController < ApplicationController
    layout 'fullscreen'

    def new
      @form = Signup::Basics.new
    end

    def create
      @form = Signup::Basics.new(form_params)

      if @form.valid?
        redirect_to signup_suitability_path(form_params)
      else
        render :new
      end
    end

    private

      def form_params
        params.require(:signup_basics).permit(
          :charity_number, :company_number, :country, :funding_type,
          :org_type, themes: []
        )
      end
  end
end
