#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param data PARAM_DESCRIPTION
#' @param levels PARAM_DESCRIPTION
#' @param direction.mat PARAM_DESCRIPTION
#' @param ... PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[plyr]{ddply}}
#'  \code{\link[tweenr]{tween_states}}
#' @rdname tween_factor
#' @export 
#' @author Jonathan Sidi
#' @importFrom plyr ddply
#' @importFrom tweenr tween_states
tween_factor <- function(data, levels, direction.mat, ...) {
  dat_center <- plyr::ddply(data, c(levels), function(x) vectorised.centroid(x[, c(1, 2)]))
  names(dat_center) <- c(levels, "x", "y")

  if (!"id" %in% colnames(direction.mat)) {
    direction.mat$id <- 1:nrow(x.in)
  }

  plyr::ddply(direction.mat, c("id"), function(x) {
    tweenr::tween_states(list(dat_center[match(x[,1],dat_center[[1]]), ], dat_center[match(x[,2],dat_center[[1]]), ]), ...)
  })
}
