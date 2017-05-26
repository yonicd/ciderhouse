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
  if(!file.exists('_archive_.txt')|update_archive){
    if(.Platform$OS.type=='windows'){
      shell('git archive --format=tar HEAD | tar t > _archive_.txt')
    }else{
      system('git archive --format=tar HEAD | tar t > _archive_.txt') 
    }
    
    if(!any(grepl('_archive_.txt',readLines('.gitignore')))) cat('_archive_.txt',file='.gitignore',sep='\n',append = TRUE)
    
    if(file.exists('.Rbuildignore')&!any(grepl('_archive_.txt',readLines('.Rbuildignore')))) cat('_archive_.txt',file='.Rbuildignore',sep='\n',append = TRUE)
    
  }
  path<-readLines('_archive_.txt')
  x <- lapply(strsplit(path, "/"), function(z) as.data.frame(t(z)))
  x <- plyr::rbind.fill(x)
  x$depth <- apply(x,1,function(y) sum(!is.na(y)))
  x<-x%>%dplyr::filter_(~(depth-lead(depth,1))!=-1)
  d3Tree::d3tree(list(root = d3Tree::df2tree(rootname='archive',struct=x),layout = layout))
  
  #invisible(x)
}