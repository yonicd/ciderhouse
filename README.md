# Package development and maintenance utility functions that I find useful

## makeImport
Function that scrapes an R file or directory of R files to create calls for namespace import. 

Instead of manually cataloging where each function is imported from this allows developer to write the R script with namespaces syntax (ie library::function) and then run the function to create the output needed for eith an roxygen header or directly to NAMESPACE

## grepDir
Function that generalizes grep in R to search in entire directory tree, returns grep by file that matches pattern. 