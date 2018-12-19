args = commandArgs(trailingOnly=TRUE)

# stablish the library path
if ( length(args) == 0 ) {
    stop("At least one argument must be supplied (R library path).n", call.=FALSE)
}
lib_path <- args[1]
.libPaths( lib_path )

# create library directory
dir.create(lib_path, showWarnings = FALSE, recursive = TRUE)

install the list of packages
list.of.packages <- c("RSQLite", "optparse", "readr", "stringi", "plyr", "Peptides", "XML")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos="http://cran.us.r-project.org", lib=lib_path)