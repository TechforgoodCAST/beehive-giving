module Api
  module V1
    class DistrictsController < ApplicationController
      respond_to :json

      def index
        @country = Country.includes(:districts).find_by(id: params[:country_id])
      end
    end
  end
end
