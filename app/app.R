## app.R ##
source("libraries.R")
source("custom_functions.R")
load("sensor_map.Rdata")
load("meta_data.Rdata")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("tab_1", tabName = "tab_rv", icon = icon("th-list")),
    menuItem("tab_2", tabName = "tab_sfdc", icon = icon("cloud"))
  )
)

body <- dashboardBody(
  # First tab content
  fluidRow(
    valueBoxOutput("vb_sensors"),
    valueBoxOutput("vb_cities"),
    valueBox(meta_summary$n_countries[1], "Countries", color = "olive", icon = icon("flag")),
    column(width = 6,
           box(
             title = "Select Sensor", width = NULL, solidHeader = TRUE, status = "primary", collapsible = TRUE,
             selectInput("sensor", "Choose a sensor:", meta_ca$sensor_name),
             textInput("threshold", "Temperature Threshold"),
             dateRangeInput("select_date", label = "Date range", start = "2017-01-01"),
             actionButton("show_stats","Show sensor values"),
             actionButton("refresh_db","Update Database")
           ),
           box(
             title = "Sensor Data - Details", width = NULL, solidHeader = TRUE, status = "primary", collapsible = TRUE,
             tableOutput("sensor_details")
           )
    ),
    column(width = 6,
           box(
             title = "Sensor Map", width = NULL, solidHeader = TRUE, status = "primary", collapsible = TRUE,
             plotOutput("out_sensor_map")
           ),
           box(
             title = "Sensor Data - Temperature", width = NULL, solidHeader = TRUE, status = "primary", collapsible = TRUE,
             ggvisOutput("ggvis_sensor_temp")
           ),
           box(
             title = "Sensor Data - Humidity", width = NULL, solidHeader = TRUE, status = "primary", collapsible = TRUE,
             ggvisOutput("ggvis_sensor_hum")
           )
    )
  )
)

ui <- dashboardPage(
  dashboardHeader(title = "Sensor Daten"),
  #sidebar,
  dashboardSidebar(disable = TRUE),
  ## Body content
  body
)


server <- function(input, output) {
  # connect to db get meta data
  con_db_meta <- mongo("meta_data", db = "sensor_db", url = mongo_url)
  meta_ca <- con_db_meta$find()
  meta_summary <- cal_db_sum(meta_ca)
  
  # render value box
  output$vb_sensors <- renderValueBox({
    valueBox(
      meta_summary$n_sensors[1], "Sensors", color = "light-blue", icon = icon("bar-chart")
    )
  })
  output$vb_cities <- renderValueBox({
    valueBox(
      meta_summary$n_cities[1], "Cities", color = "orange", icon = icon("university")
    )
  })
  
  plot_sensor_map <- generate_map(meta_ca)
  output$out_sensor_map <- renderPlot({plot_sensor_map})
  
  observeEvent(input$show_stats, {
    tmp_sensor <- get_sensor_data(input$sensor, mongo_url)
    # plot data
    if("temperature" %in% colnames(tmp_sensor)){
      ggvis_temp <- tmp_sensor %>% ggvis(~timestamp, ~temperature) %>% layer_points() %>% layer_smooths(stroke := "steelblue", strokeWidth := 6) %>% add_axis("x", title = "Time", title_offset = 50) %>%
        add_axis("y", title = "Temperature [°C]", title_offset = 50)
      ggvis_temp %>% set_options(width = "auto", height = "auto")%>% bind_shiny("ggvis_sensor_temp")
    }
    if("humidity" %in% colnames(tmp_sensor)){
      ggvis_hum <- tmp_sensor %>% ggvis(~timestamp, ~humidity) %>% layer_points() %>% layer_smooths(stroke := "steelblue", strokeWidth := 6) %>% add_axis("x", title = "Time", title_offset = 50) %>%
        add_axis("y", title = "Humidity", title_offset = 50)
      ggvis_hum %>% set_options(width = "auto", height = "auto")%>% bind_shiny("ggvis_sensor_hum")
    }
    # plot new map, check if lat, lon are NA, if not get new map
    if(!is.na(tmp_sensor$lat[1]) & !is.na(tmp_sensor$lon[1])){
      new_geo_code <- tmp_sensor[, c("lon", "lat")]
      tmp_map <- plot_sensor_map +
        geom_point(data= new_geo_code , color="steelblue", size = 4) + theme_nothing()
      output$out_sensor_map <- renderPlot({tmp_map})
    }
    tmp_details <- meta_ca %>% filter(sensor_name == input$sensor)
    tmp_details <- tmp_details[, c("sensor_name", "sensor_id", "sensor_type", "location", "lat", "lon", "date", "timezone")]
    output$sensor_details <- renderTable({tmp_details[1,]})
    
  })
  
  observeEvent(input$refresh_db, {
    
    con_db_meta <- mongo("meta_data", db = "sensor_db", url = mongo_url)
    
    # get meta data
    meta_ca <- con_db_meta$find()
    meta_summary <- cal_db_sum(meta_ca)
    
    output$vb_sensors <- renderValueBox({
      valueBox(
        meta_summary$n_sensors[1], "Sensors", color = "light-blue", icon = icon("bar-chart")
      )
    })
    output$vb_cities <- renderValueBox({
      valueBox(
        meta_summary$n_cities[1], "Cities", color = "orange", icon = icon("university")
        )
    })
    
    plot_sensor_map <- generate_map(meta_ca)
    output$out_sensor_map <- renderPlot({plot_sensor_map})  
  })  
}

shinyApp(ui, server)