library(shiny)
library(bslib)
library(bsicons)

# Define UI for app that draws a histogram ----
ui <- 
  
  fluidPage(
  #   titlePanel(div(class = "header", 
  #                  img(scr="delab_favicon.png"), 
  #                  div(class = "title", "DeLab"))),

    titlePanel(title = span(img(src = "delab_favicon.svg", height = 35), "DeLab Bot Prototype")),
    page_sidebar(
    
      #app title
  
      #title = "DeLab prototype bot (very simple)",
  
      #sidebar
      sidebar = sidebar(
        # Input: Slider for the number of bins ----
        numericInput("seed", 
                     label = "Choose conversation", 
                     value = 42
                     ) 
        ),
      
      card(
        card_header(icon("circle-info"), "Information on the Prototype"), 
        HTML("<p>Important things first: this is a prototype! 
          Don't expect the bot to run smoothly nor correctly. 
          There are many ways to improve the LLM response. 
          More information on our approach can be found on the 
          <a href='https://delab.uni-goettingen.de/en/ai-moderator'> Deliberation Laboratory website</a>.</p>")
      ), 
      
      card(
        card_header("Social media conversation"),
        dataTableOutput(outputId = "table_input"), 
        height = 300
      ),
      
      card(
        card_header("DeLab bot"),
        HTML("<p>As soon as you press the submit button, the conversation
        is submitted to the DeLab API services to extract sentiment, 
        justification, and textual similarity of the posts. Then, based 
        on the extracted features, inference takes place. If a response 
        is required, the LLM generates the response.</p>"),
           actionButton("submit", 
                        label = "Submit", 
                        width = "20%", 
                        class = "btn-primary rounded-0"),
      ), 
      
      card(
        card_header("DeLab bot response"),
        textOutput("test")
      ),
)
    
)