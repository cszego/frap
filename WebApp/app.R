library(shiny)

# UI definition
ui <- fluidPage(
  titlePanel("Real-Time MATLAB Simulation"),
  sidebarLayout(
    sidebarPanel(
      actionButton("runSim", "Run MATLAB Simulation")  # Button to trigger the MATLAB simulation
    ),
    mainPanel(
      imageOutput("plot", height = "500px")  # Display the plot here
    )
  )
)

# Server logic
server <- function(input, output) {
  
  observeEvent(input$run_sim, {
    # Run the MATLAB simulation converted to R here
    output$status <- renderText("Running Simulation...")
    
    # Placeholder for the simulation result (plot)
    output$lipid_plot <- renderPlot({
      plot_data <- data.frame(x = pos_lipids[, 3], y = pos_lipids[, 4], color = rep("blue", num_lipids))
      ggplot(plot_data, aes(x, y, color = color)) + 
        geom_point() + 
        geom_point(aes(x = focal_pos[1, 3], y = focal_pos[1, 4]), color = "red", size = 4) + 
        xlim(0, 100) + ylim(0, 100) + 
        theme_minimal()
    })
    
    # Render additional plots (speed and interaction)
    output$speed_plot <- renderPlot({
      plot(1:num_steps, avg_speed, type = "l", col = "blue", xlab = "Time", ylab = "Average Speed")
    })
    
    output$interaction_plot <- renderPlot({
      plot(1:num_steps, interaction, type = "l", col = "red", xlab = "Time", ylab = "Interactions")
    })
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)

