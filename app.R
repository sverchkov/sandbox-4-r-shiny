library(tidyverse)
library(shiny)
library(shinydashboard)
library(shinymanager)

credentials <- data.frame(
    user = c("shiny", "shinymanager"), # mandatory
    password = c("qwer", "qwer"), # mandatory
    #start = c("2019-04-15"), # optinal (all others)
    #expire = c(NA, "2019-12-31"),
    #admin = c(FALSE, TRUE),
    stringsAsFactors = FALSE
)

ui <- dashboardPage(
    dashboardHeader(title = "Basic dashboard"),
    dashboardSidebar(),
    dashboardBody(
        # Boxes need to be put in a row (or column)
        fluidRow(
            box(plotOutput("plot1", height = 250)),

            box(
                title = "Controls",
                sliderInput("slider", "Number of observations:", 1, 100, 50)
            ),

            box(
                title = "Auth",
                verbatimTextOutput("auth_output")
            ),

            box(
                title = "Data",
                dataTableOutput("table_view")
            ),

            box(
                title = "Select",
                selectizeInput(
                    "pet_select",
                    "Select the pet",
                    choices = NULL)
            ),

            box(
                verbatimTextOutput("selected_text")
            )

        )
    )
)

ui <- secure_app(ui)

server <- function(input, output, session) {

    res_auth <- secure_server(
        check_credentials = check_credentials(credentials)
    )

    output$auth_output <- renderPrint({
        reactiveValuesToList(res_auth)
    })

    data_thing <- tibble(
        date = as.Date(c("1999-01-01", "2024-05-04", "2020-06-01")),
        pet = c("dog", "cat", "snake"),
        count = c(3, 12, 98)
    )

    data_filtered <- reactive({
        if (reactiveValuesToList(res_auth)$user == "shiny"){
            data_thing %>% filter(pet != "dog")
        } else {
            data_thing
        }
    })

    set.seed(122)
    histdata <- rnorm(500)

    output$plot1 <- renderPlot({
        data <- histdata[seq_len(input$slider)]
        hist(data)
    })

    output$table_view <- renderDataTable(data_filtered())

    output$session_output <- renderPrint({
        session
    })

    observe(
        if (!is.null(reactiveValuesToList(res_auth)$user)) {
            updateSelectizeInput(
                session,
                "pet_select",
                choices = data_filtered()$pet,
                server = TRUE)
        }
    )

    output$selected_text <- renderPrint(input$pet_select)
}

shinyApp(ui, server)
