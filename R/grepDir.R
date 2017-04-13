#' @title Recursive grep
#' @description Recursive call to grep in R
#' @param pattern character string containing a regular expression
#' @param path path to search, see details
#' @param recursive logical. Should the listing recurse into directories? passed to list.files
#' @param ... arguments passed to grep
#' @return grepDir(value = FALSE) returns a vector of the indices of the elements of x 
#' that yielded a match (or not, for invert = TRUE. 
#' This will be an integer vector unless the input is a long vector, when it will be a double vector.
#' grepDir(value = TRUE) returns a character vector containing the selected elements of x 
#' (after coercion, preserving names but no other attributes).
#' @details
#' if path is a character then the pattern is checked against a location on the local machine, 
#' if path is a list with arguments containing params for ls_github(repo,subdir) 
#' then the pattern is checked on the specified github repository (repository must be public).
#' In this case of the recursive parameter takes over-rides over the list parameter.
#' @examples 
#' grepDir(pattern = 'gsub',path = '.',value=TRUE,recursive = T)
#' grepDir(pattern = 'importFrom',path = c(repo='yonicd/YSmisc',subdir='R'),value=TRUE)
#' @export
#' 
grepDir=function(pattern,path,recursive=FALSE,...){
  grepVars=list(...)
  list2env(grepVars,envir = environment())
  if(is.character(path)) fl=list.files(path,recursive = recursive,full.names = TRUE)
  if(is.list(path)){
    path$recursive=recursive
    fl=do.call(ls_github,path)
  } 
            
  out=sapply(fl,function(x){
    args=grepVars
    args$pattern=pattern
    args$x=readLines(x)
    do.call('grep',args)
  })
  out[sapply(out,length)>0]
}
