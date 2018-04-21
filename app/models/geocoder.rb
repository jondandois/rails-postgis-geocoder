# create the geocoder
class Geocoder
  def create_db
    set_gisdata_dir
    make_nationscript
  end

  private

  # postgres db connection
  def db_connection
    @db_connection ||= ActiveRecord::Base.connection
  end

  def db_config
    @db_config ||= Rails.configuration.database_configuration[Rails.env]
  end

  def gis_data_dir
    @gis_data_dir ||= ENV.fetch('GIS_DATA_DIR')
  end

  # define the gisdata dir in the tiger variables table
  def set_gisdata_dir
    raise StandardError, 'Must specify gis data dir in .env file' unless gis_data_dir.present?
    make_dir gis_data_dir
    make_dir File.join(gis_data_dir, 'temp')
    db_connection.execute(
      <<-SQL
        UPDATE tiger.loader_variables
          SET staging_fold = '#{gis_data_dir}';
      SQL
    )
  end

  def make_nationscript
    nationscript_path = File.join(gis_data_dir, 'nationscript.sh')
    result = db_connection.execute(
      <<-SQL
        SELECT loader_generate_nation_script('sh') as script;
      SQL
    )
    nationscript = result.getvalue(0,0)
    nationscript = nationscript_env_vars(nationscript)
    File.open(nationscript_path, "w") { |file| file.write nationscript }
  end

  def nationscript_env_vars(nationscript)
    nationscript.gsub!(/UNZIPTOOL=.*/, "UNZIPTOOL=#{ENV.fetch('UNZIPTOOL')}")
    nationscript.gsub!(/WGETTOOL=.*/, "WGETTOOL=#{ENV.fetch('WGETTOOL')}")
    nationscript.gsub!(/PGBIN=.*/, "PGBIN=#{ENV.fetch('PGBIN')}")
    nationscript.gsub!(/PGUSER=.*/, "PGUSER=#{ENV.fetch('PGUSER')}")
    nationscript.gsub!(/PGPASSWORD=.*/, "PGPASSWORD=#{ENV.fetch('PGPASSWORD')}")

    nationscript.gsub!(/PGPORT=.*/, "PGPORT=#{db_config['port']}")
    nationscript.gsub!(/PGHOST=.*/, "PGHOST=#{db_config['host']}")
    nationscript.gsub!(/PGDATABASE=.*/, "PGDATABASE=#{db_config['database']}")
    nationscript
  end

  # make a directory if it does not already exist
  def make_dir(dir_path)
    FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)
  end
end

