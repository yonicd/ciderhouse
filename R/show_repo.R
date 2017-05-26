#' @title Visually inspect structure of git repository before initial fetch
#' @description Visually inpsect the directory structure of it before cloning/fetching/pulling
#' @param path character, Path to root directory of git repository or a name of a github repository, Default: setwd()
#' @param layout character, Layout of d3Tree output collapse, cartesian, radial Default: 'collapse'
#' @details 
#' By default path assumes a local address, if path is a valid repository name eg 'tidyverse/glue' 
#' then the pattern is checked on the specified pulic github repository
#' @return data.frame
#' @export
#' @importFrom tools file_path_as_absolute
#' @importFrom d3Tree d3tree df2tree
#' @importFrom plyr rbind.fill
#' @importFrom htmltools html_print
#' @importFrom httr http_error
#' @examples 
#' show_repo('tidyverse/glue')
#' @seealso
#'  \code{\link[d3Tree]{d3tree}}
show_repo <- function(path=getwd(),layout='collapse'){
  this_wd <- getwd()
  if(!dir.exists(path)){
    uri <- sprintf('https://github.com/%s.git',path)
    if (httr::http_error(uri))
      stop(sprintf("github repo: %s not found", uri))
    pathout <- system(sprintf('svn ls %s/branches/master -R',uri),intern=TRUE)[-1]
  }else{
    setwd(tools::file_path_as_absolute(path))
    pathout <- system('git ls-tree -r HEAD --name-only',intern=TRUE)    
  }

  x <- lapply(strsplit(pathout, "/"), function(z) as.data.frame(t(z)))
  x <- plyr::rbind.fill(x)
  x$depth <- apply(x,1,function(y) sum(!is.na(y)))
  if(!dir.exists(path)){
    x<-x[(x$depth-c(tail(x$depth,-1),0))!=-1,]
  } 
  setwd(this_wd)
  htmltools::html_print(d3Tree::d3tree(list(root = d3Tree::df2tree(rootname='repo',struct=x),layout = layout)))
  invisible(x)
}