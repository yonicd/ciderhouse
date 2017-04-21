library(jsonlite)
library(magrittr)

raw_json<-as.data.frame(do.call('cbind',fromJSON('http://rpkg.gepuro.net/download')$pkg_list),stringsAsFactors = FALSE)

## scrape repos in group of 10K ----
# JSONS=vector('list',4L)
# K=4L
# M=10000L
# B=(1+M*(K-1)):(K*M)
# B=B[B<=nrow(raw_json)]

## read descriptions into json ----
# pb <- txtProgressBar(min = min(B),max=max(B),initial = min(B),style=3)
# jsons<-sapply(B,function(x){
#   setTxtProgressBar(pb, x)
#   out=NULL
#   a=httr::content(httr::GET(sprintf('https://raw.githubusercontent.com/%s/master/%s',raw_json$pkg_name[x],'DESCRIPTION')))
#   if(is.character(a)){
#     y=unlist(strsplit(a,'\n'))
#     a=strsplit(sub(": ", "\01", y), "\01")
#     out=sapply(a,'[',2)
#     names(out)=sapply(a,'[',1) 
#     out=as.list(out)
#     out
#   }
#   
#   ret=list(out)
#   names(ret)=raw_json$pkg_name[x]
#   toJSON(ret)
# })
# close(pb)
# 
# JSONS[[K]]=jsons

## unify and save to disk ----
#JSONS=unlist(JSONS,recursive=F)
#save(JSONS,file='gitLogs.rdata')
#write_json(JSONS,path = 'git_descriptions.json')

## unpack to list ----
lists=lapply(JSONS,fromJSON)

## reshape to dataframe ----
df=plyr::ldply(sapply(lists,'[',1),function(y){
  out=plyr::ldply(y[c('Depends','Imports','Suggests')],
                  function(x){
                    val=NULL
                    if(is.character(x)){
                      if(length(x)>0) val=gsub('\r','',strsplit(x,'[,]')[[1]])
                    }
                    data.frame(value=val,stringsAsFactors = FALSE)
                  },.id='field'
  )
  if(nrow(out)>0) out=data.frame(package=gsub('\r','',y['Package']),out,stringsAsFactors = FALSE)
  out
},.id='repo',.progress = 'text')%>%
  mutate(value=gsub('\\((.*?)\\)|\\((.*?)$','',value),
         value=gsub('^\\s+|\\s+$','',value))%>%
  filter(!grepl('\\bR\\b|^methods|^$',value)&!is.na(value))

repoSplit=data.frame(repo=df$repo,do.call('rbind',strsplit(df$repo,'/')),stringsAsFactors = FALSE)%>%distinct()
names(repoSplit)[c(2,3)]=c('user_name','repo_name')
df=df%>%left_join(repoSplit,by='repo')
df=df[names(df)[c(5,6,1,3,2,4)]]

## summarize ----
ranking=df%>%count(field,value)%>%arrange(desc(n))%>%
  do(.,cbind(rank=1:nrow(.),.))%>%
  mutate(value=sprintf('%s (%s)',value,n))%>%
  reshape2::dcast(rank~field,value.var='value')

df%>%count(field,value)%>%arrange(desc(n))%>%
  do(.,cbind(rank=1:nrow(.),.))%>%
  do(.,head(.))%>%
  mutate(value=sprintf('%s (%s)',value,n))%>%
  reshape2::dcast(rank~field,value.var='value')
