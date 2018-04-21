namespace :geocoder do
  desc 'create the geocoder database'
  task :create_db => :environment do
    geocoder = CreateGeocoder.new
    geocoder.create_db
    puts "Created Geocoder DB"
  end
end
