#' @title Visually inspect structure of git repository before initial fetch
#' @description After adding a remote visually inpsect the directory structure of it before fetching/pulling
#' @param path character, Path to root directory of git repository, Default: setwd()
#' @param layout character, Layout of d3Tree output collapse, cartesian, radial Default: 'collapse'
#' @return nothing
#' @export
#' @importFrom tools file_path_as_absolute
#' @importFrom d3Tree d3tree df2tree
#' @importFrom plyr rbind.fill
#' @seealso
#'  \code{\link[d3Tree]{d3tree}}
show_repo <- function(path=getwd(),layout='collapse'){
  this_wd <- getwd()
  setwd(tools::file_path_as_absolute(path))
  path <- system('git ls-tree -r HEAD --name-only',intern=TRUE)
  x <- lapply(strsplit(path, "/"), function(z) as.data.frame(t(z)))
  x <- plyr::rbind.fill(x)
  x$depth <- apply(x,1,function(y) sum(!is.na(y)))
  setwd(this_wd)
  htmltools::html_print(d3Tree::d3tree(list(root = d3Tree::df2tree(rootname='archive',struct=x),layout = layout)))
  invisible(x)
}