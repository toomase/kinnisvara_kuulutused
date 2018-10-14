# shiny äpp, mille abil saab pilte tag-ida

# copy app to shiny server
# cp ~/Dropbox/kinnisvara_kuulutused/shiny/random_pilt/app.R ~/ShinyApps/random_pildid/

library(shiny)
library(tidyverse)
library(magick)
library(shinyjs)

ui <- fluidPage(
  # tee radio button nuppude vahele suurem tühimik
  # https://stackoverflow.com/questions/41654766/how-to-change-the-size-and-spacing-of-check-boxes-and-radio-buttons-in-shiny-app?rq=1
  tags$style("
             .checkbox { /* checkbox is a div class*/
             line-height: 30px;
             margin-bottom: 40px; /*set the margin, so boxes don't overlap*/
             }
             input[type='checkbox']{ /* style for checkboxes */
             width: 30px; /*Desired width*/
             height: 30px; /*Desired height*/
             line-height: 30px; 
             }
             span { 
             margin-left: 15px;  /*set the margin, so boxes don't overlap labels*/
             line-height: 30px; 
             }
             "),
  useShinyjs(),
  sidebarLayout(
    sidebarPanel(
      # määra valikud, mis tag-e piltidele saab valida
      radioButtons("grupp",
                   "Vali grupp",
                   list("NONE" = 0,
                        "magamistuba" = 1,
                        "elutuba" = 2, 
                        "köök" = 3,
                        "vannituba" = 4,
                        "õuest" = 5,
                        "tühi tuba" = 6),
                   selected = 0
      ),
      actionButton("jargmine",
                   "Järgmine")
    ),
    
    mainPanel(
      # kuva pilt
      imageOutput("random_pilt")
    )
  )
  )

server <- function(input, output) {
  
  # vali üks random pilt kaustast
  # uuenda automaatselt kui klikitakse Järgmine nuppu
  pilt_sample <- eventReactive(input$jargmine, {
    pildid_path <- list.files("~/Dropbox/kinnisvara_kuulutused/data/kuulutuste_random_pildid/", 
                              full.names = TRUE)
    
    sample(pildid_path, 1)
  })
  
  # kuva see random pilt välja
  output$random_pilt <- renderImage({
    list(src = pilt_sample(),
         deleteFile = TRUE,  # kui pilti on kuvatud, siis kustuta see kaustast
         contentType = 'image/jpeg')
  })
  
  # kirjuta faili valitud tag ja faili nimeks pildi nimi/nr
  observeEvent(input$grupp, {
    if (input$grupp != 0) {
      pildi_grupp <- input$grupp
      
      tunnus_path <- str_c("~/Dropbox/kinnisvara_kuulutused/data/kuulutuste_random_pildid_tunnused/", 
                           str_extract(pilt_sample(), "[[:digit:]]{8}"), ".rds")
      
      saveRDS(pildi_grupp, tunnus_path)
    }
  })
  
  # kui mingi valik on tehtud, siis taasta algseis
  observeEvent(input$jargmine, {
    reset("grupp")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)