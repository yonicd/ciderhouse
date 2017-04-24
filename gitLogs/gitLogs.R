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

#cleaned up original JSONS file rd files using clean_description.R, resaved JSONS to
# gitLogs.rdata

load('gitLogs/gitLogs.rdata')

#get list from CRAN ----
require("tools")
getPackagesWithTitle <- function() {
  contrib.url(getOption("repos")["CRAN"], "source") 
  description <- sprintf("%s/web/packages/packages.rds",getOption("repos")["CRAN"])
  con <- if(substring(description, 1L, 7L) == "file://") {
    file(description, "rb")
  } else {
    url(description, "rb")
  }
  on.exit(close(con))
  db <- readRDS(gzcon(con))
  rownames(db) <- NULL
  
  db[, c("Package", "Title")]
}

cran_current=getPackagesWithTitle()

# created data.frame from jsons----
df=plyr::mdply(JSONS,.fun = function(x) {data.frame(fromJSON(x)[[1]],stringsAsFactors = FALSE)},.progress = 'text')
df$ON_CRAN=ifelse(df$Package%in%cran_current[,1],'CRAN_GITHUB','ONLY_GITHUB')
df1=df%>%dplyr::select(X1,ON_CRAN,Package,Title,Author,Description,Depends,Imports,Suggests,LinkingTo)%>%reshape2::melt(.,id= head(names(.),-4))%>%dplyr::filter(!is.na(value))

# clean a bit more....
df2=df1%>%plyr::ddply(head(names(df1),-1),.fun=function(x){
  data.frame(value=gsub('^\\s+|\\s+$|\\s+\\((.*?)\\)|\\((.*?)\\)|\\b.1\\b|^s: ','',strsplit(x$value,',')[[1]]),stringsAsFactors = FALSE)
},.progress = 'text')%>%filter(!grepl(':',value))

# reshape for rankings
df3<-df2%>%plyr::dlply(.variables = c('ON_CRAN'),.fun=function(df){ df%>%dplyr::count(variable,value)%>%dplyr::arrange(variable,desc(n))%>%
    dplyr::group_by(variable)%>%dplyr::do(.,cbind(rank=1:nrow(.),.))%>%
    dplyr::mutate(value=sprintf('%s (%s)',value,n))%>%
    reshape2::dcast(rank~variable,value.var='value')})

#print top 10
lapply(df3,function(x) head(x,10))
