

library(shiny)
library(ggplot2)
library(colourpicker)
library(shinyWidgets)
library(lubridate)


source("plot_graphs.R")

# Define UI for application that draws a histogram
ui <- fluidPage(
  tags$style(
    "h2, h4 {
      text-align: center;
    }"
  ),
    # Application title
  div(id="header-div",
      style = "margin: 3% auto;",
      titlePanel("Constellation Maps"),
      h4("Custom Stellar Plots"),
      ),
    

    sidebarLayout(
        sidebarPanel(
            navbarPage("Create A Custom Star Map",
                       id="navbar",
                       tabPanel("Design", value = "design",
                                colourpicker::colourInput("plot_color", "Select colour", "#191d29", palette = "limited", allowedCols = c("#191d29", "#09174A", "#053302", "#3C023D")),
                                sliderInput("glow_intensity", "Glow Intensity", min = 0.01, max=0.05, value=0.03, step = 0.01),
                                checkboxInput("show_const_name", "Show Constellation Names", value = F),
                             ),
                       tabPanel("Customize", value = "moment",
                                textInput("location_of_moment", "Location of your moment", placeholder = "City, State, Country"),
                                airDatepickerInput("date_of_moment", "The Special Date", value = lubridate::today(), todayButton = T, autoClose = T, timepicker = T),
                                textInput("special_message", "A Message (optional)", placeholder = "Your Message Here"),
                                actionButton("set_custom_values", label = "Update Values")
                             ),
                       tabPanel("Download", value="download",
                                downloadButton("download_image")
                             )
                       ) # navbarPanel
            ), # sidebarPanel

        mainPanel(
            div(id="img_wrapper",
                div(class="img_content", 
                    style = "width: 70%; margin: 0 auto;",
                    imageOutput("plot_output")
                    ) # div 
                )# div
            ) # mainPanel
        ) # sidebarLayout
    ) # fluidPage

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    listener <- reactive({
        list(input$plot_color,
             input$show_const_name,
             input$glow_intensity,
             input$set_custom_values
             )
        })
    
    
    
    rv <- reactiveValues(plot = NULL)
    
    observe({
        rv$plot <- get_default_celestial_map()
    })
    

    
    observeEvent(listener(), {
        
        bg_fill_col <- input$plot_color
        glowint <- input$glow_intensity
        
        desired_place <- ifelse(is.na(input$location_of_moment) || input$location_of_moment == "",
                               "Seoul, Korea",
                               input$location_of_moment)

        year_ <- lubridate::year(input$date_of_moment)
        month_ <- lubridate::month(input$date_of_moment)
        day_ <- lubridate::day(input$date_of_moment)
        
        hour_ <- lubridate::hour(input$date_of_moment)
        min_ <- lubridate::minute(input$date_of_moment)
        
        glow_intensity <- input$glow_intensity
        special_message <- input$special_message
        show_const_name <- input$show_const_name # Pass an argument to indicate whether to hide constellation names
        
        
        rv$plot <- get_custom_celestial_map(desired_place, year_, month_, day_, hour_, min_, special_message,
                                            bg_fill_col, glowint, show_const_name)
        
    })  
    
    
    output$plot_output <- renderImage({
        
        if (!is.null(rv$plot)) {
            # Create a temporary file name for the plot
            tmp <- tempfile(fileext = ".png")
            # Save the plot as a png image
            ggsave(tmp, rv$plot, width = 8, height = 10, dpi = 300)
            # Return the png image
            list(src = tmp, width = "100%", height = "auto", alt = "starmap")
        }
    }, deleteFile = TRUE)
    
    output$download_image <- downloadHandler(
        
        filename = function() {
            loc <- ifelse(is.na(input$location_of_moment) || input$location_of_moment == "", "Seoul", input$location_of_moment)
            paste0("starmap","_",loc, ".png")
            },
        
        content = function(file) {
            if (!is.null(rv$plot)) {
                ggsave(file, rv$plot, width = 8, height = 10, dpi = 300)
            }
        }
    )
    
}

# Run the application 
shinyApp(ui = ui, server = server)
