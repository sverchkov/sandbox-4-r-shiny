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


    set.seed(122)
    histdata <- rnorm(500)

    output$plot1 <- renderPlot({
        data <- histdata[seq_len(input$slider)]
        hist(data)
    })
}

shinyApp(ui, server)
