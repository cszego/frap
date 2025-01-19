#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # Observe the button click to run the MATLAB simulation
  observeEvent(input$runSim, {
    # Run the MATLAB script (assuming MATLAB is installed and accessible)
    system("diffusion.m")  # Replace with your MATLAB script name
    
    # Dynamically update the plot every 0.1 seconds (or any appropriate interval)
    output$plot <- renderImage({
      list(src = "current_plot.png", contentType = "image/png", width = 600, height = 400)
    }, deleteFile = FALSE)  # Keep the file after the session ends
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
