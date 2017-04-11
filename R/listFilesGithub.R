#' @title List files of a github repository subdirectory
#' @description List full raw paths to files in a github repository subdirectory
#' @param repo character Repository address in the format username/repo
#' @param subdir subdirectory within repo that contains the files to list
#' @importFrom rvest html_nodes html_text
#' @importFrom xml2 read_html
#' @examples 
#' l=list.files_github('tidyverse/ggplot2')
#' l
#' #geom-boxplot.r
#' readLines(l[42])
#' @export
list.files_github=function(repo,subdir='R'){
root=sprintf('https://github.com/%s/tree/master/%s',repo,subdir)
xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "css-truncate-target", " " ))]//*[contains(concat( " ", @class, " " ), concat( " ", "js-navigation-open", " " ))]'
s=xml2::read_html(root)%>%rvest::html_nodes(xpath=xpath)%>%rvest::html_text()
#ggplot2::ggplot()
sprintf('https://raw.githubusercontent.com/%s/master/%s/%s',repo,subdir,s)
}