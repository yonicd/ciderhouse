w<-c('email','from','Your','Name','with','contributions',
  'Who','wrote','it','person','Some','good','guy','See','AUTHORS','file','Author',
  'Please','feel','free','to','contact','Dr','Scientific','Software','Development',
  'under','the','supervision','of','wrten','-shim','AuthorR','AuthorsR','many','others')

w1<-sprintf("[\\'.\\{\\}:\\/=@]| - |%s",paste0(sprintf("\\b%s\\b",w),collapse = '|'))

getAuthor=function(a){
x<-sapply(a$Author,function(x){
  s=gsub('<(.*?)>|\\[(.*?)\\]|\\((.*?)\\)',',',x)
  s=gsub('[\\"\\)\\&0-9;+]|\\n|\\band\\b|^$|\\bby\\b|\\bextending\\b',',',s)
  s=gsub(w1,'',s)
  
  s=gsub('á','a',s)
  s=gsub('Wickham Hadley','Hadley Wickham',s)
  s=gsub('Kent Russell|Russell Kent','Kenton Russell',s)
  s=gsub('Karl Broman','Karl W Broman',s)
  s=gsub('Rob Tibshirani','Robert Tibshirani',s)
  
  s=strsplit(s,',')[[1]]
  gsub('^\\s+|\\s+$','',s)
})

names(x)=a$Package

plyr::ldply(x,function(y){
  data.frame(Author=unique(as.character(y[grepl(' ',y)])),stringsAsFactors = FALSE)
},.id='Package',.progress = 'text')

}

gitAuthor<-getAuthor(out$raw)%>%distinct()


gitAuthor%>%count(Author)%>%arrange(desc(n))%>%
top_n(20) %>%
  mutate(Author = reorder(Author, n)) %>%
  ggplot(aes(Author, n)) +
  geom_col(fill = "cyan4", alpha = 0.8,position = 'dodge',show.legend = FALSE) +
  coord_flip() +
  scale_y_continuous(expand = c(0,0)) +
  labs(x = NULL, y = "Number of Mentions in Author Field",
       title = "Who are the most common authors in CRAN and Github package descriptions?")

x<-gitAuthor%>%filter(Package%in%cran_current[,1])%>%count(Author)%>%arrange(desc(n))%>%filter(n>=10)

Author_cors<-gitAuthor%>%filter(Author%in%x$Author)%>%
  mutate_each(funs(as.character))%>%ungroup%>%
  pairwise_cor(Author, Package, sort = TRUE)


filtered_cors <- Author_cors%>%
  filter(correlation > 0.1)

vertices <- x%>%ungroup%>%filter(Author %in% filtered_cors$item1)

set.seed(1234)
filtered_cors %>%
  graph_from_data_frame(vertices = vertices) %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = correlation), width = 2) +
  geom_node_point(aes(size = n), color = "cyan4") +
  geom_node_text(aes(label = name), repel = TRUE, point.padding = unit(0.2, "lines")) +
  theme_graph() +
  scale_size_continuous(range = c(1, 15)) +
  labs(size = "Number of packages",
       edge_alpha = "Correlation",
       title = "Author correlations in R package descriptions *only* on CRAN",
       subtitle = "Cliques of R package authors")
