#' @title List files of a github repository subdirectory
#' @description List full raw paths to files in a github repository subdirectory
#' @param repo character Repository address in the format username/repo
#' @param subdir subdirectory within repo that contains the files to list
#' @importFrom httr content GET
#' @examples 
#' l=ls_github('tidyverse/ggplot2')
#' l
#' #geom-boxplot.r
#' readLines(l[42])
#' @export
ls_github=function(repo,subdir=NULL,recursive=FALSE){

r=''
if(!is.null(subdir)) r='?recursive=1'  
tr=httr::content(httr::GET(sprintf('https://api.github.com/repos/%s/git/trees/master%s',repo,r)))$tree
s=sapply(tr,function(x) if(x$mode!='040000') x$path)

if(!is.null(subdir)){
  s=grep(paste0('^',subdir,'/'),s,value=TRUE)
  g=grep(sprintf('(/.*){%s,}',min(nchar(gsub('[^//]','',s)))+1),s)
  if(length(g)>0) if(!recursive) s=s[-g]
}else{
  s=unlist(s)
} 
sprintf('https://raw.githubusercontent.com/%s/master/%s',repo,s)
}
