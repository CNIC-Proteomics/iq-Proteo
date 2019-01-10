#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if ( length(args)==0 ) {
    stop("At least one argument must be supplied: output directory\n", call.=FALSE)
}

# stablish the library path
lib_path <- args[1]
.libPaths( lib_path )

# create library directory
dir.create(lib_path, showWarnings = FALSE, recursive = TRUE)

# install the list of packages
list.of.packages <- c("RSQLite", "optparse", "readr", "stringi", "plyr", "Peptides", "XML", "data.table")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos="http://cran.us.r-project.org", lib=lib_path)