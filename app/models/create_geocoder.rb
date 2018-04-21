# create the geocoder
class CreateGeocoder
  def create_db
    set_gisdata_dir
    make_nationscript
    make_statescript
    run_nationscript
    run_statescript
    install_missing_indexes
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

  #################################################
  ###  NATIONSCRIPT
  #################################################

  def nationscript_path
    @nationscript_path ||= File.join(gis_data_dir, 'nationscript.sh')
  end

  def make_nationscript
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts "Preparing nationscript:"
    result = db_connection.execute(
      <<-SQL
        SELECT loader_generate_nation_script('sh');
      SQL
    )
    nationscript = result.values.join("\n\n\n\n\n")
    nationscript = script_env_vars(nationscript)
    File.open(nationscript_path, "w") { |file| file.write nationscript }
  end

  def run_nationscript
    system("sh #{nationscript_path}")
  end

  #################################################
  ###  STATESCRIPT
  #################################################

  def statescript_path
    @statescript_path ||= File.join(gis_data_dir, 'statescript.sh')
  end

  def make_statescript
    states = ENV.fetch('STATES').split(',')
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts "statescript for the following states:"
    states.each { |s| puts s }
    puts "This can take a long time to run..."
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    sleep(5)
    puts "Continuing"
    states.map! { |s| "'#{s}'" }
    states_array = "ARRAY[#{states.join(',')}]"
    result = db_connection.execute(
      <<-SQL
        SELECT loader_generate_script(#{states_array}, 'sh');
      SQL
    )
    statescript = result.values.join("\n\n\n\n\n")
    statescript = script_env_vars(statescript)
    File.open(statescript_path, "w") { |file| file.write statescript }
  end

  def run_statescript
    system("sh #{statescript_path}")
  end

  #################################################
  ###  HELPERS
  #################################################

  # installs remaining geocoder indexes after data has been loaded
  def install_missing_indexes
    db_connection.execute(
      <<-SQL
        SELECT install_missing_indexes();
      SQL
    )
  end

  def script_env_vars(script)
    script.gsub!(/UNZIPTOOL=.*/, "UNZIPTOOL=#{ENV.fetch('UNZIPTOOL')}")
    script.gsub!(/WGETTOOL=.*/, "WGETTOOL=#{ENV.fetch('WGETTOOL')}")
    script.gsub!(/PGBIN=.*/, "PGBIN=#{ENV.fetch('PGBIN')}")
    script.gsub!(/PGUSER=.*/, "PGUSER=#{ENV.fetch('PGUSER')}")
    script.gsub!(/PGPASSWORD=.*/, "PGPASSWORD=#{ENV.fetch('PGPASSWORD')}")

    script.gsub!(/PGPORT=.*/, "PGPORT=#{db_config['port']}")
    script.gsub!(/PGHOST=.*/, "PGHOST=#{db_config['host']}")
    script.gsub!(/PGDATABASE=.*/, "PGDATABASE=#{db_config['database']}")
    script
  end

  # make a directory if it does not already exist
  def make_dir(dir_path)
    FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)
  end
end

