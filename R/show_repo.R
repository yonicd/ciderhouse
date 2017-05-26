#' @title Visually inspect structure of git repository before initial fetch
#' @description After adding a remote visually inpsect the directory structure of it before fetching/pulling
#' @param layout charaacter, Layout of d3Tree output collapse, cartesian, radial Default: 'collapse'
#' @return nothing
#' @export
#' @importFrom plyr rbind.fill
#' @importFrom d3Tree d3tree df2tree
#' @seealso
#'  \code{\link[d3Tree]{d3tree}}
show_repo <- function(layout='collapse'){
  path <- system('git ls-tree -r HEAD --name-only',intern=TRUE)
  x <- lapply(strsplit(path, "/"), function(z) as.data.frame(t(z)))
  x <- plyr::rbind.fill(x)%>%mutate_if(is.factor,as.character)
  x$depth <- apply(x,1,function(y) sum(!is.na(y)))
  d3Tree::d3tree(list(root = d3Tree::df2tree(rootname='archive',struct=x),layout = layout))
  #invisible(x)
}