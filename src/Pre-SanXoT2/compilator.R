#############################
#
# compilator
#
#############################

pwd <- paste0( Sys.getenv(c("IQPROTEO_HOME")), "/venv_win64")
lib_path <- paste0( pwd, "/R/library")
.libPaths( lib_path )

list.of.packages <- c("optparse", "data.table")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos="http://cran.us.r-project.org", lib=lib_path)
library("optparse")
library("data.table")

# get input parameters
option_list = list(
  make_option(c("-i", "--indir"), type="character", default=NULL, help="input directory with SanXoT results", metavar="character"),
  make_option(c("-r", "--regex"), type="character", default=NULL, help="Regular expression that selects the specific SanXoT results", metavar="character"),
  make_option(c("-o", "--outfile"), type="character", default=NULL, help="output file", metavar="character")
);
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);


# BEGIN: IMPORTANT!!!! HARD-CORE inputs!!!
# opt$indir <- "S:/LAB_JVC/RESULTADOS/JM RC/iq-Proteo/WF/temp"
# opt$regex <- "^c2a_outs_outStats"
# opt$outfile <- "S:/LAB_JVC/RESULTADOS/JM RC/iq-Proteo/WF/results/c2a_outs_outStats.tsv"
# END: IMPORTANT!!!! HARD-CORE inputs!!!

if ( is.null(opt$indir) || is.null(opt$regex) || is.null(opt$outfile) ) {
  print_help(opt_parser)
  stop("All arguments must be supplied.n", call.=FALSE)
}

print( "input parameters: ")
print( opt )

print("get the list of SanXoT results from the given directory")
in_files <- list.files(path = opt$indir, pattern=opt$regex, full.names = TRUE, recursive = TRUE)
print(in_files)

print("merge the list of results")
all <- NULL
for (in_file in in_files) {
  # extract the experiment name and tag name from the file name
  dnames <- unlist( regmatches(in_file, gregexpr("([^\\|/])+", in_file)) )
  n <- length(dnames)
  tag <- dnames[n-2]
  exp <- dnames[n-3]
  # read and add the experiment and tag columns
  tmp <- fread(in_file, sep="\t", quote = "?", header=TRUE)
  tmp <- cbind(tmp,Tag=tag)
  tmp <- cbind(tmp,Expto=exp)
  # merge with the rest of files
  all <- rbind(all, tmp)
}
print("write ouput file")
fwrite(all, opt$outfile, sep="\t", quote = FALSE, row.names=FALSE)
  