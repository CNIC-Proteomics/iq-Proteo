#############################
#
# Pre-SanXoT2: create_id-q   #
#
#############################

# # pwd <- "D:\projects\qProteo\venv_win64"
pwd <- paste0( Sys.getenv(c("QPROTEO_HOME")), "/venv_win64")
lib_path <- paste0( pwd, "/R/library")
.libPaths( lib_path )

list.of.packages <- c("optparse", "readr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos="http://cran.us.r-project.org", lib=lib_path)
library("optparse")
library("readr")

# get input parameters
option_list = list(
  make_option(c("-i", "--in_ident"), type="character", default=NULL, help="input file from PD", metavar="character"),
  make_option(c("-q", "--in_quant"), type="character", default=NULL, help="input file from pRatio", metavar="character"),
  make_option(c("-t", "--tags"), type="character", default=NULL, help="Tags Used in the Experiment. Eg. '126,127_N,127_C,128_N,128_C,129_N,129_C,130_N,130_C,131'", metavar="character"),
  make_option(c("-n", "--ratio_numer"), type="character", default=NULL, help="List of all numerators.One or more elements. Eg. '127_N,127_C,128_N,128_C,129_N,129_C,130_N,130_C,131'", metavar="character"),
  make_option(c("-d", "--ratio_denom"), type="character", default=NULL, help="Unique denominator of ratio for all numerator elements. One or more elements. Eg. '130_C,131,129_C,129_N'", metavar="character"),
  make_option(c("--abs_calc"), type="character", default="both", help="To Absolute Quantification (true = Absolute Quantification, false = Relative Quantification or both = Both) [default= %default]", metavar="character"),  
  make_option(c("--random"), type="logical", default=TRUE, help="Calculate all against all tags [default= %default]", metavar="character"),
  make_option(c("-f", "--filt_orphans"), type="logical", default=TRUE, help="Comet-PTM input: Filter the orphans and No_Mod_Mass [default= %default]", metavar="character"),
  make_option(c("--no_mod_mass"), type="double", default=-0.000163, help="Comet-PTM input: Mass of No modified [default= %default]", metavar="character"),
  make_option(c("-o", "--outfile"), type="character", default=NULL, help="output file", metavar="character")
);
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# BEGIN: IMPORTANT!!!! HARD-CORE inputs!!!

# Edema_Oxidation_timecourse_Cys_pig Test input: ---
# opt$in_ident <- "D:/projects/qProteo/test/Edema_Oxidation_timecourse_Cys_pig/PTMs/TMT1/ID-all.txt"
# opt$in_quant <- "D:/projects/qProteo/test/Edema_Oxidation_timecourse_Cys_pig/PTMs/TMT1/Q-all.csv"
# opt$tags <- "126,127_N,127_C,128_N,128_C,129_N,129_C,130_N,130_C,131"
# opt$ratio_numer <- "127_N,127_C,128_N,128_C,129_N,129_C,130_N,130_C,131"
# opt$ratio_denom <- "126"
# opt$abs_calc = "False"
# opt$random = FALSE
# opt$filt_orphans <- TRUE
# opt$no_mod_mass <- -0.000163
# opt$outfile <- "D:/projects/qProteo/test/Edema_Oxidation_timecourse_Cys_pig/PTMs/qproteo/TMT1/ID-q.txt"

# PESA_omicas Test input: ---
# opt$in_ident <- "D:/projects/qProteo/test/PESA_omicas/6a_Cohorte_70_Female_V1_V2/TMT_Fraccionamiento/TMT9/ID-all.txt"
# opt$in_quant <- "D:/projects/qProteo/test/PESA_omicas/6a_Cohorte_70_Female_V1_V2/TMT_Fraccionamiento/TMT9/Q-all.csv"
# opt$tags <- "126,127_N,127_C,128_N,128_C,129_N,129_C,130_N,130_C,131"
# opt$ratio_numer <- "126,127_N,127_C,128_N,128_C,129_N,129_C,130_N,130_C,131"
# opt$ratio_denom <- "126,131"
# opt$abs_calc = "Both"
# opt$random = TRUE
# opt$filt_orphans <- FALSE
# opt$no_mod_mass <- NULL
# opt$outfile <- "D:/projects/qProteo/test/PESA_omicas/6a_Cohorte_70_Female_V1_V2/TMT_Fraccionamiento/TMT9/ID-q.txt"

# END: IMPORTANT!!!! HARD-CORE inputs!!!


if ( is.null(opt$in_ident) || is.null(opt$in_quant) || is.null(opt$outfile) && file.exists(opt$in_ident) && file.exists(opt$in_quant) ) {
  print_help(opt_parser)
  stop("All arguments must be supplied.n", call.=FALSE)
}

# transform some input parameters in array
opt$in_ident <- normalizePath(opt$in_ident, winslash = "/")
opt$in_quant <- normalizePath(opt$in_quant, winslash = "/")
opt$tags <- unlist( strsplit(opt$tags, ",") )
if ( !is.null(opt$ratio_numer) ) {opt$ratio_numer <- unlist( strsplit(opt$ratio_numer, ",") ) }
if ( !is.null(opt$ratio_denom) ) {opt$ratio_denom <- unlist( strsplit(opt$ratio_denom, ",") ) }
opt$outfile <- normalizePath(opt$outfile, winslash = "/")
opt$outdir <- dirname(opt$outfile)

print( "input parameters: ")
print( opt )

# calculate the quantification
calculate_IDq <- function(q_all, ID_all, tags, ratio_numer, ratio_denom, abs_calc, random) {
  
  # begin: for debugging
  # tags = opt$tags
  # ratio_numer = opt$ratio_numer
  # ratio_denom = opt$ratio_denom
  # abs_calc = opt$abs_calc
  # random = opt$random
  # end: for debugging
  
  # re-assign input variables
  k <- q_all
  x <- ID_all
  
  # create a column with the join of two columns
  x$Raw_FirstScan<-do.call(paste, c(x[c("RAWFile","FirstScan")], sep = ""))
  k$Raw_FirstScan<-do.call(paste, c(k[c("FileName","FirstScan")], sep = ""))
  x$Raw_FirstScan<-as.character(x$Raw_FirstScan)
  k$Raw_FirstScan<-as.character(k$Raw_FirstScan)
  
  # add the colnames for the tags
  TagsUsed=paste0("X",tags)
  colnames_tags=c("Raw_FirstScan")
  colnames_tags=append(colnames_tags, TagsUsed)
  q <- k[,colnames_tags]
  
  all <- merge(x,q)
  
  # get the index of columns that will be compared taking into account the list of numerators.
  CalcIndex <- NULL
  for ( ratio_num in ratio_numer ) {
    RatioNumIndex=as.numeric(grep(paste0("X",ratio_num), colnames(all)))
    CalcIndex = c( CalcIndex, RatioNumIndex)
  }
  
  # calculate the mean
  if ( length(ratio_denom) > 1 ) {
    all$Mean <- rowMeans(all[,paste0("X",ratio_denom)], na.rm = TRUE)
    MeanIndex=as.numeric(grep("Mean", colnames(all)))
  } else {
    ControlIndex=as.numeric(grep(paste0("X",ratio_denom), colnames(all)))
  }
  
  for (i in CalcIndex) {
    
    if ( length(ratio_denom) > 1 ) {
      all$newcolumn <- log2(all[,i]/all$Mean)
      l <- substring(colnames(all)[i],2)
      colnames(all)[ncol(all)] <- paste0("Xs_",l,"_Mean")
    } else {
      all$newcolumn <- log2(all[,i]/all[,ControlIndex])
      l <- substring(colnames(all)[i],2)
      colnames(all)[ncol(all)] <- paste0("Xs_",l,"_",ratio_denom)
    }
    
    if (toupper(abs_calc) == "TRUE"){
      all$newcolumn <- all[,c(i)]
      colnames(all)[ncol(all)] <- paste0("Vs_",l,"_ABS")
    }
    
    if (toupper(abs_calc) == "FALSE") {
      if ( length(ratio_denom) > 1 ) {
        all$newcolumn <- apply(all[,c(i,MeanIndex)], 1, max)
        colnames(all)[ncol(all)] <- paste0("Vs_",l,"_Mean")
      } else {
        all$newcolumn <- apply(all[,c(i,ControlIndex)], 1, max)
        colnames(all)[ncol(all)] <- paste0("Vs_",l,"_",ratio_denom)
      }
    }
    
    if (toupper(abs_calc) == "BOTH") {
      all$newcolumn <- all[,c(i)]
      colnames(all)[ncol(all)] <- paste0("Vs_",l,"_ABS")
      if ( length(ratio_denom) > 1 ) {
        all$newcolumn <- apply(all[,c(i,MeanIndex)], 1, max)
        colnames(all)[ncol(all)] <- paste0("Vs_",l,"_Mean")
      } else {
        all$newcolumn <- apply(all[,c(i,ControlIndex)], 1, max)
        colnames(all)[ncol(all)] <- paste0("Vs_",l,"_",ratio_denom)
      }
    }
  }
  
  # Calculate all against all tags
  if (toupper(random) == TRUE){
    for (i in CalcIndex){
      for (m in CalcIndex) {
        all$newcolumn <- log2(all[,i]/all[,m])
        l <- substring(colnames(all)[i],2)
        o <- substring(colnames(all)[m],2)
        colnames(all)[ncol(all)] <- paste0("Xs_",l,"_",o)
        all$newcolumn <- apply(all[,c(i,m)], 1, max)
        colnames(all)[ncol(all)] <- paste0("Vs_",l,"_",o)
      }
    }
  }  
  
  return ( all )
} # end calculate_IDq

# MAIN ---------

# create workspace
dir.create(opt$outdir, showWarnings = FALSE, recursive = TRUE)

# create the ID-all from the all pRatio results
ID_all <- read.table(file = opt$in_ident, sep = "\t", comment.char = "?",quote = "\"", header=TRUE, check.names=FALSE)

# read the quantification file
q_all <- read.table(file = opt$in_quant, sep = ",", header=TRUE)

# Shifts input:
if ( "Protein" %in% colnames(ID_all) && "FileName" %in% colnames(ID_all) && "Scan" %in% colnames(ID_all) ) {
  # delete _INV_ label
  ID_all <- subset(ID_all, !grepl("_INV_",ID_all$Protein))
  
  # rename the raw file from txt to raw
  ID_all$FileName<-sub(pattern=".txt", replacement = ".raw", ID_all$FileName)
  
  # rename the columns
  colnames(ID_all)[which(names(ID_all)=="FileName")] <- "RAWFile"
  colnames(ID_all)[which(names(ID_all)=="Scan")] <- "FirstScan"
} 

# calculate the ratio: the Xs and Vs
all <- calculate_IDq(q_all, ID_all, opt$tags, opt$ratio_numer, opt$ratio_denom, opt$abs_calc, opt$random)

# Shifts input: 
if ( "Corr_mass" %in% colnames(ID_all) && "FinalSeq_Mass" %in% colnames(ID_all) && "fastaDescription" %in% colnames(ID_all) ) {
  
  # change the Corr_mas
  all$Corr_mass <- round(all$Corr_mass, digits = 6)
  
  all$FinalSeq_Mass <- paste0(substr(
    all$FinalSeq_Mass,
    1,
    gregexpr("\\[", all$FinalSeq_Mass)),
    all$Corr_mass,
    substr(
      all$FinalSeq_Mass,
      gregexpr("]", all$FinalSeq_Mass),
      nchar(as.character(all$FinalSeq_Mass))
    ))
  
  # changes the header names
  colnames(all)[which(names(all)=="fastaDescription")] <- "FASTAProteinDescription"
  colnames(all)[which(names(all)=="FinalSeq_Mass")] <- "Sequence"
  colnames(all)[which(names(all)=="Corr_mass")] <- "Mod_Mass"
}

# filter section ------------------
if ( opt$filt_orphans ) {
  
  # Take into account the 6 digits!! Talk with Elena
  all <- subset(all, all[,39] >= -56, Corr_mass = formatC(all$Corr_mass, digits=6, format='f'))
  
  # Filter out orphans
  all <- all[is.na(all[,36]),]
  all_no_mod <- subset(all, all[,39] == opt$no_mod_mass)
  all_no_mod <- cbind(all_no_mod, Modified = "FALSE")
  
  # Mark the Modified peptides from the No_Modified_Mass
  all_mod <- subset(all, all[,39] != opt$no_mod_mass)
  all_mod <- cbind(all_mod, Modified = "TRUE")
  
  all_final <- rbind(all_no_mod, all_mod)
  
} else {
  all_final <- all
}

# print output file
# outfile <- paste(opt$outdir,"/ID-q.txt",sep="")
write_tsv(all_final, opt$outfile)

