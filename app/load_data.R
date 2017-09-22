source("libraries.R")

import_to_db <- function(folder, db_url = url, offset_value = 0){
  # connect to mongo db
  con_db_meta <- mongo("meta_data", db = "sensor_db", url = db_url)
  
  # loops over each file in folder and imports ".csv" data
  file_names <- list.files(path=folder, pattern="*.csv", full.names=T, recursive=FALSE)
  for(i in 1:length(file_names)){
    
    tmp_df <- read_delim(file_names[i], col_names = TRUE, delim = ";")
    
    if(nrow(tmp_df) != 0){
      # create dataframe and copy to db
      
      # meta data
      con_db_meta$insert(data.frame(sensor_name = paste("sensor", i + offset_value, sep = "_") ,id = paste(tmp_df$sensor_id[1], ymd(as.Date(tmp_df$timestamp[1])), sep = "_"), sensor_id = tmp_df$sensor_id[1], sensor_type = tmp_df$sensor_type[1], location = tmp_df$location[1], lat = tmp_df$lat[1], lon = tmp_df$lon[1],  date = ymd(as.Date(tmp_df$timestamp[1])), timezone = attr(tmp_df$timestamp[1], "tzone")))
      
      
      # sensor data
      con_db_sensor <- mongo(paste("sensor_", i, sep = ""), db = "sensor_db", url = db_url)
      con_db_sensor$insert(tmp_df)
    }
    # print progress
    print(paste(i, " of ", length(file_names), sep = ""))
  }
}


import_to_db("./data", mongo_url)
