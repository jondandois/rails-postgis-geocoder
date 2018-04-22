# A utility class to perform geocodes against the db
class GeocodeUtil
  class << self
    def search(params)
      return build_response('invalid request, address empty', :bad_request) unless params[:address].present?
      result = {}

      res = make_query(params[:address])
      if res.present? && res.values.present?
        result = {
          status: :ok,
          results: res.each { |r| r }
        }
      else
        result = {
          status: :bad_request,
          results: 'no results'
        }
      end
      result
    end

    def geocode_assertion(address)
      <<-SQL
        SELECT
          g.rating AS rating,
          ST_X(ST_SnapToGrid(geomout, 0.00001)) AS lng,
          ST_Y(ST_SnapToGrid(geomout, 0.00001)) AS lat,
          ST_Y(ST_SnapToGrid(geomout, 0.00001)) || ', ' || ST_X(ST_SnapToGrid(geomout, 0.00001)) as lat_lng,
          pprint_addy(addy) AS address
        FROM
          geocode(
            pagc_normalize_address(#{address})
          )
        AS g;
      SQL
    end

    # postgres db connection
    def db_connection
      @db_connection ||= ActiveRecord::Base.connection
    end

    def make_query(address)
      safe_address = db_connection.quote(address.html_safe)
      res = []
      begin
        res = db_connection.execute(geocode_assertion(safe_address))
      rescue ActiveRecord::StatementInvalid => e
        Rails.logger.warn { "Invalid Statement generated for type assertion:\n#{e}" }
      end
      res
    end

    def build_response(message, status)
      { message: message,
        status: status}
    end
  end
end
