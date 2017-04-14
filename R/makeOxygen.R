#' @title Creates scaffolding of roxygen header from function script
#' @description Creates roxygen header scaffolding including title, description, import and other fields
#' @param obj function or name of function
#' @param add_defaults logical to add defaults values to the end of the PARAM fields 
#' @param add_fields character vector to add additional roxygen fields, Default: NULL
#' @details add_fields can include (concept,keyword,usage,export,details,examples). the order in add_fields
#' determines the order of printout.
#' @examples 
#' makeOxygen(stats::lm,add_default = TRUE,add_fields = c('export','examples'))
#' @export
makeOxygen=function(obj,add_default=TRUE, add_fields=NULL,...){
  if(is.character(obj)) obj=eval(parse(text=obj))
  
  
  importList=list(...)
  importList$script=obj
  importList$print=FALSE
  import=do.call('makeImport',importList)
  
  str_out='PARAM_DESCRIPTION'
  
  out=sapply(formals(obj),function(y){
    cl=class(y)
    out=as.character(y)
    if(cl=='NULL') out='NULL'
    if(cl=='character') out=sprintf("'%s'",as.character(y))
    if(cl%in%c('if','call')) out=deparse(y)
    out=paste0(out,collapse ="\n#'")
    if(add_default){
        if(nchar(out)>0){
          out=sprintf(", Default: %s",out)
        }
      str_out=sprintf('PARAM_DESCRIPTION%s',out)
    }
    
    return(str_out)
  })
  
  header=c(title="#' @title FUNCTION_TITLE",
           description="#' @description FUNCTION_DESCRIPTION")
  
  header_add=c(
    concept="#' @concept CONCEPT_TERM",
    keyword="#' @keyword KEYWORD_TERM",
    usage="#' @usage USAGE_DESCRIPTION",
    export="#' @export",
    details="#' @details DETAILS",
    examples="#' @examples\n#' EXAMPLE1 \n"
  )
  
  writeLines(
    sprintf('%s\n%s\n%s%s',
            paste(header,collapse = '\n'),
            paste(sprintf("#' @param %s %s",names(out),out),collapse='\n'),
            ifelse(!is.null(add_fields),paste(header_add[add_fields],collapse = '\n'),''),
            import
    )
  )
  
}
