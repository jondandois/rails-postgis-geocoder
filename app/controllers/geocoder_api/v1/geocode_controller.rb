# GeocoderApi Namespace
module GeocoderApi
  # API Version 1
  module V1
    class GeocodeController < ApplicationController
      # basic geocode search
      def search
        address = search_params[:address]
        @result = GeocodeUtil.search(address: address)
        render status: @result[:status]
      end

      private

      def search_params
        params.permit %i[address]
      end
    end
  end
end
