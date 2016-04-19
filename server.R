library(shiny)
library(tm)
library(wordcloud)
library(twitteR)
shinyServer(function(input, output, session) {
  consumerKey <- "<CONSUMER_KEY>"
  consumerSecret <- "<CONSUMER_SECRET>"
  accessToken <- "<ACCESS_TOKEN>"
  accessTokenSecret <- "<ACCESS_TOKEN_SECRET>"
  
  setup_twitter_oauth(consumerKey, consumerSecret, 
                      accessToken, accessTokenSecret)
  
  token <- get("oauth_token", twitteR:::oauth_cache)
  
  token$cache()
  
  output$currentTime <- renderText({invalidateLater(1000, session) 
    paste("Current time is: ",Sys.time())})
  
  observe({
    
    invalidateLater(60000,session)
    
    count_positive = 0
    count_negative = 0
    count_neutral = 0
    
    positive_text <- vector()
    negative_text <- vector()
    neutral_text <- vector()
    
    vector_users <- vector()
    vector_sentiments <- vector()
    keyword = "nike"
    tweets_result = ""
    
    #tweets_result = searchTwitter("to:nike", n=200)
    tweets_result = userTimeline("nike", n=1000)
    for (tweet in tweets_result){
      print(paste(tweet$screenName, ":", tweet$text))
      
      vector_users <- c(vector_users, as.character(tweet$screenName));
      
      if (grepl("love", tweet$text, ignore.case = TRUE) | 
          grepl("wonder", tweet$text, ignore.case = TRUE) | 
          grepl("awesome", tweet$text, ignore.case = TRUE) |
          grepl("amaz", tweet$text, ignore.case = TRUE)){
        count_positive = count_positive + 1
        
        vector_sentiments <- c(vector_sentiments, "Positive")
        positive_text <- c(positive_text, as.character(tweet$text))
        
      } else if (grepl("boring", tweet$text, ignore.case = TRUE) | 
                 grepl("hate", tweet$text, ignore.case = TRUE) |
                 grepl("meh", tweet$text, ignore.case = TRUE)) { 
        count_negative = count_negative + 1
        
        vector_sentiments <- c(vector_sentiments, "Negative")
        negative_text <- c(negative_text, as.character(tweet$text))
        
      } else {
        count_neutral = count_neutral + 1
        print("neutral")
        vector_sentiments <- c(vector_sentiments, "Neutral")
        neutral_text <- c(neutral_text, as.character(neutral_text))
      }
    }
    
    df_users_sentiment <- data.frame(vector_users, vector_sentiments)
    
    output$tweets_table = renderDataTable({
      df_users_sentiment
    })
    
    output$distPlot <- renderPlot({
      
      results = data.frame(tweets = c("Positive", "Negative", "Neutral"), numbers = c(count_positive,count_negative,count_neutral))
      
      barplot(results$numbers, names = results$tweets, xlab = "Sentiment", ylab = "Counts", col = c("Green","Red","Blue"))
      
      if (length(positive_text) > 0){
        
        output$positive_wordcloud <- renderPlot({ wordcloud(paste(iconv(positive_text, 'UTF-8', 'ASCII'), collapse=" "), min.freq = 0, random.color=TRUE, max.words=100 ,colors=brewer.pal(8, "Dark2")) }) 
      }
      
      if (length(negative_text) > 0) {
        
        output$negative_wordcloud <- renderPlot({ wordcloud(paste(iconv(negative_text, 'UTF-8', 'ASCII'), collapse=" "), min.freq = 0, random.color=TRUE, max.words=100 ,colors=brewer.pal(8,"Set3")) }) 
      }
      
      if (length(neutral_text) > 0){
        
        output$neutral_wordcloud <- renderPlot({ wordcloud(paste(iconv(neutral_text, 'UTF-8', 'ASCII'), collapse=" "), min.freq = 0, random.color=TRUE , max.words=100 ,colors=brewer.pal(8, "Dark2")) }) 
      }
      
    })
  })
})