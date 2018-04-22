# Rails PostGIS TIGER Geocoder API

This is an example PostGIS geocoder API built using TIGER census data and providing a simple `search?address=` endpoint via Rails.

The PostGIS DB configuration is based off of the examples provided in [PostGIS in Action](http://www.postgis.us/).

### Requirements
- Ruby 2.4.3
- Postgres 9.6 with PostGIS 2.3
- unzip
- wget

### Building Geocoder
- Copy the `example.env` file to `.env`
- Specify your local settings for each of the configuration options in the `.env` file:
    - `GIS_DATA_DIR`= path to a directory you have permission to write to where gis data will be staged before being added to the db
    - `UNZIPTOOL`= path to your unzip binary
    - `WGETTOOL`= path to your wget binary
    - `PGBIN`=path to your postgres binary _directory_
    - `PGUSER`= postgres user name
    - `PGPASSWORD`= postgres password or `''` if none
    - `STATES`= a comma separated list of US State and Territory two letter postal codes.  The full list can be found in the `example.env` file, but beware, running this on all states will require a significant amount of time and 100's GB of disk space
  - Initialize the db with rails: `rake db:create db:migrate`
  - Run the geocoder create_db rake task to download state data and build the geocoder indexes! `rake geocoder:create_db`

Once that is done, run `rails s` and start geocoding at: `http://localhost:5000/geocoder_api/geocode/search?address=`

#### Geocoding Results:
Results will be returned as JSON in a results object and are sorted by closest match (smallest `rating` value):
```
http://localhost:5000/geocoder_api/geocode/search?address=1500%20fleet%20street%20baltimore%20md
{
  "results": [
    {
      "rating": 1,
      "lng": -76.596,
      "lat": 39.28454,
      "lat_lng": "39.28454, -76.596",
      "address": "1500 Fleet St, Baltimore, MD 21231"
    },
    {
      "rating": 8,
      "lng": -76.58034,
      "lat": 39.28519,
      "lat_lng": "39.28519, -76.58034",
      "address": "2526 Fleet St, Baltimore, MD 21224"
    }
  ]
}
```

If no results were found: `{ "results": "no results" }` is returned.

#### States Codes
The `example.env` is configured for `MD` only.  Here is a list of all valid US State 2 letter codes:
```
  STATES=AK,AL,AR,AS,AZ,CA,CO,CT,DC,DE,FL,GA,GU,HI,IA,ID,IL,IN,KS,KY,LA,MA,MD,ME,MI,MN,MO,MP,MS,MT, \
  NC,ND,NE,NH,NJ,NM,NV,NY,OH,OK,OR,PA,PR,RI,SC,SD,TN,TX,UT,VA,VI,VT,WA,WI,WV,WY
```
