require("tools")
library(jsonlite)
library(magrittr)
library(plyr)
library(dplyr)


update_repos_list<-function(){
  load('gitLogs/current_repo_list.Rdata')
  raw_json<-as.data.frame(do.call('cbind',fromJSON('http://rpkg.gepuro.net/download')$pkg_list),stringsAsFactors = FALSE)
  raw_json$pkg_name[which(!raw_json$pkg_name%in%JSONS.names)]
}

fetch_description<-function(new_repos){
pb <- txtProgressBar(min = 1,max=length(new_repos),initial = 1,style=3)
jsons<-sapply(1:length(new_repos),function(x){
  setTxtProgressBar(pb, x)
  out=NULL
  out=httr::content(httr::GET(sprintf('https://raw.githubusercontent.com/%s/master/%s',new_repos[x],'DESCRIPTION')))
  ret=list(out)
  names(ret)=new_repos[x]
ret
})
close(pb)
return(jsons)
}

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

reshape_description=function(parse_descriptions){
  a=plyr::mdply(parse_descriptions[!is.na(parse_descriptions)],.fun = function(x) {
    data.frame(fromJSON(x)[[1]],stringsAsFactors = FALSE)},.progress = 'text')
  a$ON_CRAN=ifelse(a$Package%in%cran_current[,1],'CRAN_GITHUB','ONLY_GITHUB')
  a$repo=names(jsons)[!is.na(parse_descriptions)][as.numeric(a$X1)]
  a1=a%>%dplyr::select(X1,ON_CRAN,repo,Package,Title,Author,Description,Depends,Imports,Suggests,LinkingTo)%>%
    reshape2::melt(.,id= head(names(.),-4))%>%dplyr::filter(!is.na(value))
  
  # clean a bit more....
  a2=a1%>%plyr::ddply(head(names(a1),-1),.fun=function(x){
    data.frame(value=gsub('^\\s+|\\s+$|\\s+\\((.*?)\\)|\\((.*?)\\)|\\b.1\\b|^s: ','',strsplit(x$value,',')[[1]]),stringsAsFactors = FALSE)
  },.progress = 'text')%>%dplyr::filter(!grepl(':|NULL',value))
  
  # reshape for rankings
  a3<-a2%>%plyr::dlply(.variables = c('ON_CRAN'),.fun=function(df){ df%>%dplyr::count(variable,value)%>%dplyr::arrange(variable,desc(n))%>%
      dplyr::group_by(variable)%>%dplyr::do(.,cbind(rank=1:nrow(.),.))%>%
      dplyr::mutate(value=sprintf('%s (%s)',value,n))%>%
      reshape2::dcast(rank~variable,value.var='value')})
  l=list(raw=a,clean=a2,ranking=a3)
  
  return(l)
}


new_repos=update_repos_list()

jsons=fetch_description(new_repos)
load('gitLogs/gitLogs.rdata')

parse_descriptions<-rep(NA,length(jsons))

for(i in 1:length(jsons)){
  x=jsons[[i]]
    if(!inherits(x,'raw')){
      if(!is.na(x)){
        f<-tempfile()
        cat(x,file = f)
        out=read.dcf(f)
        unlink(f)
        l=list(as.list(as.data.frame(out,stringsAsFactors = FALSE)))
        names(l)=names(jsons[i])
        parse_descriptions[i]<-toJSON(l)
    }
    }
  }

cran_current=getPackagesWithTitle()

JSONS=c(JSONS,parse_descriptions[!is.na(parse_descriptions)])

out=reshape_description(JSONS)

#print top 10
lapply(out$ranking,function(x) head(x,10))

JSONS=c(JSONS,parse_descriptions[!is.na(parse_descriptions)])
save(JSONS,file='gitLogs/gitLogs.rdata')
JSON.names=sapply(JSONS,function(x) names(fromJSON(x)))
save(JSONS.names,file='gitLogs/current_repo_list.Rdata')
