#' @title Recursive grep
#' @description Recursive call to grep in R
#' @param pattern character string containing a regular expression
#' @param path path to search
#' @param recursive logical. Should the listing recurse into directories? passed to list.files
#' @param ... arguments passed to grep
#' @return grepDir(value = FALSE) returns a vector of the indices of the elements of x that yielded a match (or not, for invert = TRUE. 
#' This will be an integer vector unless the input is a long vector, when it will be a double vector.
#' grepDir(value = TRUE) returns a character vector containing the selected elements of x (after coercion, preserving names but no other attributes).
#' @export
#' 
grepDir=function(pattern,path,recursive=FALSE,...){
  grepVars=list(...)
  list2env(grepVars,envir = environment())
  fl=list.files(path,recursive = recursive,full.names = TRUE)
  out=sapply(fl,function(x){
    args=grepVars
    args$pattern=pattern
    args$x=readLines(x)
    do.call('grep',args)
  })
  out[sapply(out,length)>0]
}
