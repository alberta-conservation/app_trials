library(shiny)
library(webshot2)
library(htmltools)
library(chromote)

ui <- fluidPage(
  titlePanel("Convert renderUI to PDF via webshot2"),
  
  # The UI output displayed in the app
  uiOutput("myHTMLReport"),
  
  hr(),
  downloadButton("downloadPdf", "Download as PDF")
)

server <- function(input, output, session) {
  
  # 1. Define a reactive expression that generates your HTML content
  report_content <- reactive({
    tagList(
      h1("Dynamic Report Layout"),
      p("This layout is captured via headless Chrome and outputted directly to PDF."),
      tags$ul(
        tags$li("Item 1"),
        tags$li("Item 2")
      )
    )
  })
  
  # 2. Display the HTML in the Shiny application
  output$myHTMLReport <- renderUI({
    report_content()
  })
  
  # 3. Handle the PDF download using webshot2
  output$downloadPdf <- downloadHandler(
    filename = function() {
      paste0("report-webshot-", Sys.Date(), ".pdf")
    },
    content = function(file) {
      # Create a temporary file path for the intermediate HTML file
      temp_html <- tempfile(fileext = ".html")
      
      # Use save_html to export the reactive HTML tags to a file
      htmltools::save_html(report_content(), temp_html)
      
      # Use webshot2 to render the local HTML file directly into a PDF
      webshot2::webshot(
        url = temp_html, 
        file = file, 
        vwidth = 800,   # Set view width in pixels
        vheight = 1100  # Set view height in pixels
      )
    }
  )
}

shinyApp(ui, server)
