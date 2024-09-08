library(shiny)
library(bslib)

# Define UI for app that draws a histogram ----
ui <- 
  
  fluidPage(
  #   titlePanel(div(class = "header", 
  #                  img(scr="delab_favicon.png"), 
  #                  div(class = "title", "DeLab"))),

    page_sidebar(
    
      #app title
  
      title = "DeLab prototype bot (very simple)",
  
      #sidebar
      sidebar = sidebar(
        # Input: Slider for the number of bins ----
        numericInput("seed", 
                     label = "Choose conversation", 
                     value = 42
                     ) 
        ),
      
      card(
        card_header("Social media conversation"),
        dataTableOutput(outputId = "table_input")
      ),
      
      card(
        card_header("Your post"),
        textInput("user_post", 
                  label = NULL,
                  width = "100%",
                  placeholder = "Take part in the conversation and submit a post."), 
           actionButton("submit", 
                        label = "Submit", 
                        width = "20%"),
      ), 
      
      card(
        card_header("DeLab bot response"),
        textOutput("test")
      ),
)
    
)