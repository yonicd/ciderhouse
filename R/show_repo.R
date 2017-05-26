#' @title Visually inspect structure of git repository before initial fetch
#' @description After adding a remote visually inpsect the directory structure of it before fetching/pulling
#' @param layout charaacter, Layout of d3Tree output collapse, cartesian, radial Default: 'collapse'
#' @param update_archive boolean, update the archive file, Default: FALSE
#' @return nothing
#' @export
#' @import dplyr
#' @importFrom plyr rbind.fill
#' @importFrom d3Tree d3tree df2tree
#' @seealso
#'  \code{\link[d3Tree]{d3tree}}
show_repo <- function(layout='collapse',update_archive=FALSE){
  p_type=.Platform$OS.type
  git_remote=system('git remote -v',intern=TRUE)
  git_branch=gsub('^\\* ','',grep('^\\* ',system('git branch',intern=TRUE),value=TRUE))
  is_github=all(grepl('github.com',git_remote))
  
  if(is_github){
    git_repo=gsub('.git(.*?)$','',gsub('^(.*?).com/','',git_remote[1]))
    tr<-httr::content(httr::GET(sprintf('https://api.github.com/repos/%s/git/trees/%s%s',git_repo,git_branch,'?recursive=1')))$tree
    s=sapply(tr,function(x) if(x$mode!='040000') x$path)
    path<-unlist(s)
  }else{
  if(!file.exists('_archive_.txt')|update_archive){
    if(.Platform$OS.type=='windows'){
      shell('git archive --format=tar HEAD | tar t > _archive_.txt')
    }else{
      system('git archive --format=tar HEAD | tar t > _archive_.txt') 
    }
    
    if(!any(grepl('_archive_.txt',readLines('.gitignore')))) cat('_archive_.txt',file='.gitignore',sep='\n',append = TRUE)
    
    if(file.exists('.Rbuildignore')&!any(grepl('_archive_.txt',readLines('.Rbuildignore')))) cat('_archive_.txt',file='.Rbuildignore',sep='\n',append = TRUE)
    
  }
  
  tr<-httr::content(httr::GET(sprintf('https://api.github.com/repos/%s/git/trees/%s%s','yonicd/ciderhouse','master','')))$tree
  s=sapply(tr,function(x) if(x$mode!='040000') x$path)
  
  path<-readLines('_archive_.txt')
  }
  
  x <- lapply(strsplit(path, "/"), function(z) as.data.frame(t(z)))
  x <- plyr::rbind.fill(x)%>%mutate_if(is.factor,as.character)
  x$depth <- apply(x,1,function(y) sum(!is.na(y)))
  if(!is_github) x<-x%>%dplyr::filter_(~(depth-lead(depth,1))!=-1)
  d3Tree::d3tree(list(root = d3Tree::df2tree(rootname='archive',struct=x),layout = layout))
  #invisible(x)
}