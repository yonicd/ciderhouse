w<-c('email','from','Your','Name','with','contributions',
  'Who','wrote','it','person','Some','good','guy','See','AUTHORS','file','Author',
  'Please','feel','free','to','contact','Dr','Scientific','Software','Development',
  'under','the','supervision','of','wrten','-shim','AuthorR','AuthorsR')

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
  
  s=strsplit(s,',')[[1]]
  gsub('^\\s+|\\s+$','',s)
})

names(x)=a$Package

plyr::ldply(x,function(y){
  data.frame(Author=unique(as.character(y[grepl(' ',y)])),stringsAsFactors = FALSE)
},.id='Package',.progress = 'text')

}

gitAuthor<-getAuthor(out$raw)%>%distinct()


gitAuthor%>%count(Author)%>%arrange(desc(n))%>%View
