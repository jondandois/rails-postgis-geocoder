class AddExtensions < ActiveRecord::Migration[5.2]
  def change
    enable_extension "postgis"
    enable_extension "fuzzystrmatch"
    enable_extension "postgis_tiger_geocoder"
    enable_extension "address_standardizer"
  end
end
