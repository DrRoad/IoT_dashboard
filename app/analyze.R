source("libraries.R")


#mongo_url <-  "mongodb://127.0.0.1:27017"

con_db_meta <- mongo("meta_data", db = "sensor_db", url = mongo_url)

# get meta data
meta_ca <- con_db_meta$find()

# plot map
geo_code <- meta_ca[, c("lon", "lat")]
sensor_map <- get_map(location = "Germany", zoom = 6,
                  source = "stamen", maptype = "toner")

# Add a geom_points layer
plot_sensor_map <- ggmap(sensor_map) + geom_point(data= geo_code , color="orange", size = 4) + theme_nothing()
plot_sensor_map

save(plot_sensor_map, geo_code, file="sensor_map.Rdata")

#################################

# summarize meta data

meta_summary <- meta_ca %>%
    summarise(n_sensors = n(), n_cities = n_distinct(location), n_countries = 12)

save(meta_ca, meta_summary, file="meta_data.Rdata")

#################################


# get sensor data for specific sensor id
get_sensor_data <- function(f_sensor_name = "sensor_1", db_url = url){
  # generate database name and connect to db
  #tmp_db_name <- 
  con_db_sensor <- mongo(f_sensor_name, db = "sensor_db", url = db_url)
  # get data and calculate timestamp
  tmp_df <- con_db_sensor$find()
  tmp_df$timestamp <- as.POSIXct(tmp_df$timestamp, origin = "1960-01-01", tz = tmp_df$timezone)
  return(tmp_df)
}


tmp_sensor <- get_sensor_data("sensor_10", mongo_url)

