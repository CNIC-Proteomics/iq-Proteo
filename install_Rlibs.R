# stablish the library path
lib_path <- paste0( Sys.getenv(c("IQPROTEO_LIBRARY")), "/R")
print( lib_path )
.libPaths( lib_path )

# create library directory
dir.create(lib_path, showWarnings = FALSE, recursive = TRUE)

# install the list of packages
list.of.packages <- c("RSQLite", "optparse", "readr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos="http://cran.us.r-project.org", lib=lib_path)