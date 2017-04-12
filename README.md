# Package development and maintenance utility functions that I find useful

## makeImport
Function that scrapes an R file or directory of R files to create calls for namespace import. 

Instead of manually cataloging where each function is imported from this allows developer to write the R script with namespaces syntax (ie library::function) and then run the function to create the output needed for eith an roxygen header or directly to NAMESPACE

When you are building a package to submit to cran and you need to have namespace calls for any function that is being imported.

It is a pain (at least for me) to manually parse through the code looking for all the `*::*` and writing it in the roxygen header.

this function does that for you. 

you can write normally your script with the namespace calls and in the end run the function and you can paste the output into the header. 

The function is written to work on single files or whole dirs (like in a package R subdir).

The addin uses the active document in the RStudio editor console as the file argument.

```r
makeImport(file=list.files_github('yonicd/YSmisc','R'),print = T,format = 'oxygen')
 
https://raw.githubusercontent.com/yonicd/YSmisc/master/R/grepDir.R

 
https://raw.githubusercontent.com/yonicd/YSmisc/master/R/listFilesGithub.R
@importFrom rvest html_nodes html_text
@importFrom xml2 read_html
 
https://raw.githubusercontent.com/yonicd/YSmisc/master/R/makeImport.R
@importFrom stringr str_extract_all
@importFrom utils installed.packages

makeImport(file=list.files_github('yonicd/YSmisc','R'),print = T,format = 'namespace')
 
importFrom(rvest,html_nodes)
importFrom(rvest,html_text)
importFrom(stringr,str_extract_all)
importFrom(utils,installed.packages)
importFrom(xml2,read_html)
```

## grepDir
Function that generalizes grep in R to search in entire directory tree, returns grep by file that matches pattern. 

## list.files_github
Return raw paths to files in github directory. Useful when combined with readLines and the first two functions.

```r
list.files_github('yonicd/YSmisc','R')
[1] "https://raw.githubusercontent.com/yonicd/YSmisc/master/R/grepDir.R"        
[2] "https://raw.githubusercontent.com/yonicd/YSmisc/master/R/listFilesGithub.R"
[3] "https://raw.githubusercontent.com/yonicd/YSmisc/master/R/makeImport.R"

list.files_github('tidyverse/ggplot2','R')%>%head(.,20)
 [1] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/aaa-.r"                   
 [2] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/aes-calculated.r"         
 [3] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/aes-colour-fill-alpha.r"  
 [4] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/aes-group-order.r"        
 [5] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/aes-linetype-size-shape.r"
 [6] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/aes-position.r"           
 [7] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/aes.r"                    
 [8] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/annotation-custom.r"      
 [9] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/annotation-logticks.r"    
[10] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/annotation-map.r"         
[11] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/annotation-raster.r"      
[12] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/annotation.r"             
[13] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/autolayer.r"              
[14] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/autoplot.r"               
[15] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/axis-secondary.R"         
[16] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/bench.r"                  
[17] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/bin.R"                    
[18] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/coord-.r"                 
[19] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/coord-cartesian-.r"       
[20] "https://raw.githubusercontent.com/tidyverse/ggplot2/master/R/coord-fixed.r"
```