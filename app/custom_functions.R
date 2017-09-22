get_sensor_data <- function(f_sensor_name = "sensor_1", db_url = url){
  # generate database name and connect to db
  #tmp_db_name <- 
  con_db_sensor <- mongo(f_sensor_name, db = "sensor_db", url = db_url)
  # get data and calculate timestamp
  tmp_df <- con_db_sensor$find()
  tmp_df$timestamp <- as.POSIXct(tmp_df$timestamp, origin = "1960-01-01", tz = tmp_df$timezone)
  return(tmp_df)
}

get_db_stats <- function(db_url = url){
  # get meta data and calculate stats
  con_db_meta <- mongo("meta_data", db = "sensor_db", url = db_url)
  
  # get meta data
  meta_ca <- con_db_meta$find()
  
  meta_summary <- meta_ca %>%
    summarise(n_sensors = n(), n_cities = n_distinct(location), n_countries = 12)
  
  return(meta_summary)
}

#meta_summary <- get_db_stats(mongo_url)


cal_db_sum <- function(f_df){
  meta_summary <- f_df %>%
    summarise(n_sensors = n(), n_cities = n_distinct(location), n_countries = 12)
  
  return(meta_summary)
}

generate_map <- function(f_df){
  geo_code <- f_df[, c("lon", "lat")]
  sensor_map <- get_map(location = "Germany", zoom = 6,
                        source = "stamen", maptype = "toner")
  
  # Add a geom_points layer
  plot_sensor_map <- ggmap(sensor_map) + geom_point(data= geo_code , color="orange", size = 4) + theme_nothing()
  return(plot_sensor_map)
}