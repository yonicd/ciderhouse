#' @title Visually inspect structure of git repository before initial fetch
#' @description After adding a remote visually inpsect the directory structure of it before fetching/pulling
#' @param layout charaacter, Layout of d3Tree output collapse, cartesian, radial Default: 'collapse'
#' @return nothing
#' @export
#' @import dplyr
#' @importFrom plyr rbind.fill
#' @importFrom d3Tree d3tree df2tree
#' @seealso
#'  \code{\link[d3Tree]{d3tree}}
show_repo <- function(layout='collapse'){
  system('git archive --format=tar HEAD | tar t > _archive_.txt')
  path<-readLines('_archive_.txt')
  system('rm _archive_.txt')
  x <- lapply(strsplit(path, "/"), function(z) as.data.frame(t(z)))
  x <- plyr::rbind.fill(x)
  x$depth <- apply(x,1,function(y) sum(!is.na(y)))
  x<-x%>%dplyr::filter_(~(depth-lead(depth,1))!=-1)
  d3Tree::d3tree(list(root = d3Tree::df2tree(rootname='archive',struct=x),layout = layout))
  
  #invisible(x)
}