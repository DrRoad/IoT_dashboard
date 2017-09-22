source("libraries.R")

# docker run -d -p 27017:27017 mongo

mongo_url <-  "mongodb://127.0.0.1:27017"


con_db <- mongo("sensor_2", db = "sensor_db", url = mongo_url)


con_db$count()
con_db$find()
con_db$find('{"sensor_id": 94}')


