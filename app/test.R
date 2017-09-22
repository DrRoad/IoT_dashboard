# get meta data and calculate stats
con_db_meta <- mongo("meta_data", db = "sensor_db", url = mongo_url)

# get meta data
meta_ca <- con_db_meta$find()

meta_summary <- meta_ca %>%
  summarise(n_sensors = n(), n_cities = n_distinct(location), n_countries = 12)
