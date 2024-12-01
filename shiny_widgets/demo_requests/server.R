#packages
library(tidyverse)
library(httr2)
#library(emoji)
library(DT)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  ############################## data
  #load conversation data
  load("./../../data/conv_delab.rda")
  
  #keep only conversations with at least XX posts
  conv_delab <- conv_delab |> 
    dplyr::group_by(conv_id, conv_path) |> 
    dplyr::mutate(freq_posts = n()) |> 
    dplyr::ungroup() |> 
    dplyr::filter(freq_posts >= 4)

  ############################## SHOW INPUT
  output$table_input <- renderDataTable({
    
    ############################## sampling
    #set seed
    seed_number <- input$seed
    set.seed(seed_number)
    
    #sample conv id
    id_sample <- conv_delab |>
      dplyr::mutate(conv_id_path = str_c(conv_id, "_", conv_path)) |> 
      dplyr::select(conv_id_path) |>
      unique() |> 
      dplyr::slice(seed_number)
    
    conv_sample <- conv_delab |> 
      dplyr::mutate(conv_id_path = str_c(conv_id, "_", conv_path)) |> 
      dplyr::filter(conv_id_path == id_sample$conv_id_path) 
    
    ############################## authors & text
    conv_input <- conv_sample |> 
      dplyr::select(author_id, text) |> 
      dplyr::mutate(post_id = row_number()) |>
      #mutate(input = str_c("id", post_id, " - ", author_id, " - ", text)) |> 
      dplyr::select(post_id, author_id, text)
    
    DT::datatable(conv_input, 
                  options = list(scrollY = FALSE, 
                                 dom = 't'),
                  rownames = FALSE)
  })
  
  ############################## USER SUBMIT
  observeEvent(input$submit, {
    
      ############################## sampling
      #set seed
      seed_number <- input$seed
      set.seed(seed_number)
      
      #sample conv id
      id_sample <- conv_delab |>
        dplyr::mutate(conv_id_path = str_c(conv_id, "_", conv_path)) |> 
        dplyr::select(conv_id_path) |>
        unique() |> 
        dplyr::slice(seed_number)
      
      conv_sample <- conv_delab |> 
        dplyr::mutate(conv_id_path = str_c(conv_id, "_", conv_path)) |> 
        dplyr::filter(conv_id_path == id_sample$conv_id_path) 
      
      ############################## authors & text
      conv_input <- conv_sample |> 
        dplyr::select(author_id, text) |> 
        dplyr::mutate(post_id = row_number()) |>
        #mutate(input = str_c("id", post_id, " - ", author_id, " - ", text)) |> 
        dplyr::select(post_id, author_id, text)
      
      llm_input <- c(conv_input$text)

      #replace emojis
      #llm_input <- emoji_replace_all(llm_input, "_emoji_")
      
      #run llm
      url <- request('http://services.localhost:8840/')
      
      req <- url |>
        req_url_path_append("llm") |>
        #req_url_query(analytics = "cosine") |> 
        req_body_json(list(texts = llm_input))
      
      #actual request
      current_request <- req |>
        req_perform(verbosity = 0)
      
      #extract data
      current_raw <- current_request |>
        resp_body_json() |> 
        pluck("df") |> 
        enframe() |> 
        unnest_wider(value)

      current_raw <- as.character(current_raw)

      output$test <- renderText({current_raw})

    })

  

}