# Package development and maintenance utility functions that I find useful

## makeImport
Function that scrapes an R file or directory of R files to create calls for namespace import. 

Instead of manually cataloging where each function is imported from this allows developer to write the R script with namespaces syntax (ie library::function) and then run the function to create the output needed for eith an roxygen header or directly to NAMESPACE

```r
makeImport(list.files_github('yonicd/YSmisc','R'),print = T,format = 'oxygen')
 
https://raw.githubusercontent.com/yonicd/YSmisc/master/R/grepDir.R

https://raw.githubusercontent.com/yonicd/YSmisc/master/R/makeImport.R
@importFrom stringr str_extract_all
@importFrom utils installed.packages

makeImport(list.files_github('yonicd/YSmisc','R'),print = T,format = 'namespace')
 
importFrom(stringr,str_extract_all)
importFrom(utils,installed.packages)
```

## grepDir
Function that generalizes grep in R to search in entire directory tree, returns grep by file that matches pattern. 

## list.files_github
Return raw paths to files in github directory. Useful when combined with readLines and the first two functions.

```r
list.files_github('yonicd/YSmisc','R')
[1] "https://raw.githubusercontent.com/yonicd/YSmisc/master/R/grepDir.R"   
[2] "https://raw.githubusercontent.com/yonicd/YSmisc/master/R/makeImport.R"
```