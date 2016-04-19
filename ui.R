#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Sentiment Analysis"),
  
  textOutput("currentTime"),
  h4("Tweets:"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      dataTableOutput('tweets_table')
      
    ),
    
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot"),
      sidebarPanel(
        plotOutput("positive_wordcloud")
      ),
      sidebarPanel(
        plotOutput("negative_wordcloud")
      ),
      sidebarPanel(
        plotOutput("neutral_wordcloud")
      )
    )
    
  )
))