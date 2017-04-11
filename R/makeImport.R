#' @title Scrape R script to create namespace calls
#' @description Scrape r script to create namespace calls for roxygen and namespace file
#' @param file character connection to pass to readLines, can be file path, directory path, url path
#' @param cut integer number of functions to write as importFrom until switches to import
#' @param print boolean print output to console, default FALSE
#' @param format character the output format must be in c('oxygen','namespace'), default oxygen
#' @examples 
#' makeImport(list.files_github('yonicd/YSmisc','R'),print = T,format = 'oxygen')
#' makeImport(list.files_github('yonicd/YSmisc','R'),print = T,format = 'namespace')
#' @export
#' @importFrom stringr str_extract_all
#' @importFrom utils installed.packages
makeImport=function(file,cut=NULL,print=FALSE,format='oxygen'){
  rInst<-paste0(row.names(utils::installed.packages()),'::')
  pkg=sapply(file,function(f){
  x<-readLines(f,warn = F)
  x=x[!grepl('^#',x)]
  s0=sapply(paste0('\\b',rInst,'\\b'),grep,x=x,value=TRUE)
  s1=s0[which(sapply(s0,function(y) length(y)>0))]
  names(s1)=gsub('\\\\b','',names(s1))
  ret=sapply(names(s1),function(nm){
    out=unlist(lapply(s1[[nm]],function(x){
      y=gsub('[\\",(]','',unlist(stringr::str_extract_all(x,pattern=paste0(nm,'(.*?)\\('))))
      names(y)=NULL
      y 
    }))
    out=unique(out)
    if(format=='oxygen'){
      ret=paste0("#' @importFrom ",gsub('::',' ',nm),gsub(nm,'',paste(unique(out),collapse = ' ')))
      if(!is.null(cut)){
        if(length(out)>=cut) ret=paste0("#' @import ",gsub('::','',nm))
      } 
      out=ret
    }
    return(out)
  })
  if(format=='oxygen') writeLines(paste(' ',f,paste(ret,collapse='\n'),sep = '\n'))
  return(ret)
  })
  
  if(format=='oxygen') ret=pkg
  
  if(format=='namespace'){
    pkg=sort(unique(unlist(pkg)))
    ret=paste0('importFrom(',gsub('::',',',pkg),')')
    retWrite=paste(' ',paste(ret,collapse='\n'),sep = '\n')
    if(print) writeLines(retWrite)
  }
  
  invisible(ret)
}