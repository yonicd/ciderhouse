#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param polygon PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname vectorised.centroid
#' @export 
#' @author Jonathan Sidi
vectorised.centroid <- function(polygon) {
  ix <- c(2:dim(polygon)[1], 1)
  xs <- polygon[, 1]
  xr <- xs[ix]
  ys <- polygon[, 2]
  yr <- ys[ix]
  factor <- xr * ys - xs * yr
  cx <- sum((xs + xr) * factor)
  cy <- sum((ys + yr) * factor)
  scale <- 3 * abs(sum(xs * yr) - sum(xr * ys))
  c(cx / scale, cy / scale)
}
