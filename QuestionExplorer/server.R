
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)



shinyServer(function(input, output, session) { 
  
  y <- reactive(getQfam(input$SurveyNames))
  
  output$qtype <-  DT::renderDataTable(y(), server=TRUE, filter="top")
  
  observeEvent(input$CompanyNames, {
    companyfilter <- companyName[company_desc == input$CompanyNames, company_cd]
    updateSelectInput(session, "SurveyNames", choices = 
                surveyName$survey_cd[surveyName$company_cd %in% companyfilter])
  })
  
})
