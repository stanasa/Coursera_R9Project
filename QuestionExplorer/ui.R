
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
source("helpers.R")

shinyUI(fluidPage(

  pageWithSidebar(
    headerPanel("Voz Latinum Question Explorer"),
    
    sidebarPanel(
      selectInput(inputId = "CompanyNames", "Select a company:",
                  choices="Latinum Network"),
      
      tags$hr(),
      
      selectInput(inputId = "SurveyNames", "Select a survey:",
                  choices = surveyName$survey_cd),
      width=3
    ),    
    mainPanel(DT::dataTableOutput("qtype"))
  )))
