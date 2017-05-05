library(igraph)
library(ggraph)
library(widyr)

cran <- tbl_df(out$clean%>%select(Package,Description)%>%distinct())
cran$ON_CRAN=ifelse(cran$Package%in%cran_current[,1],'CRAN_GITHUB','ONLY_GITHUB')

tidy_cran <- cran %>%group_by(ON_CRAN)%>%
  unnest_tokens(word, Description)

word_totals <- tidy_cran %>%
  anti_join(stop_words) %>%
  count(word, sort = TRUE)

word_totals %>% group_by(ON_CRAN)%>%
  top_n(20) %>%arrange(ON_CRAN,desc(n))%>%filter(!is.na(word))%>%ungroup%>%
  do(.,cbind(id=rep(stringr::str_pad(1:20,2,'left','0'),2),.))%>%
  mutate(word1=paste(id,word,sep='_'))%>%
  ggplot(aes(word1, n)) +
  geom_col(aes(fill = ON_CRAN), alpha = 0.8,position = 'dodge',show.legend = FALSE) +
  coord_flip() +
  scale_y_continuous(expand = c(0,0)) +
  labs(x = NULL, y = "Number of uses in CRAN descriptions",
       title = "What are the most commonly used words in CRAN and Github package descriptions?",
       subtitle = "After removing stop words")+facet_wrap(~ON_CRAN,scales = 'free_y')

netPlot <- dlply(tidy_cran%>%filter(!is.na(ON_CRAN)),c('ON_CRAN'),.fun=function(df){
  word_cors<-df%>%
    anti_join(stop_words) %>%
    group_by(word) %>%
    filter(n() > 150) %>% # filter for words used at least 150 times
    ungroup %>%
    pairwise_cor(word, Package, sort = TRUE)
  
  
  filtered_cors <- word_cors%>%
    filter(correlation > 0.2,
           item1 %in% word_totals$word,
           item2 %in% word_totals$word)
  
  vertices <- word_totals %>%ungroup%>%filter(ON_CRAN==unique(df$ON_CRAN))%>%
    filter(word %in% filtered_cors$item1)%>%select(-ON_CRAN)
  
  set.seed(1234)
  plotOut=filtered_cors %>%
    graph_from_data_frame(vertices = vertices) %>%
    ggraph(layout = "fr") +
    geom_edge_link(aes(edge_alpha = correlation), width = 2) +
    geom_node_point(aes(size = n), color = "cyan4") +
    geom_node_text(aes(label = name), repel = TRUE, point.padding = unit(0.2, "lines")) +
    theme_graph() +
    scale_size_continuous(range = c(1, 15)) +
    labs(size = "Number of uses",
         edge_alpha = "Correlation",
         title = sprintf("Word correlations in R package descriptions: %s",unique(df$ON_CRAN)),
         subtitle = "Which words are more likely to occur together than with other words?")

  list(plot=plotOut,word_cors=word_cors,filtered_cors=filtered_cors,vertices=vertices)
      
})

