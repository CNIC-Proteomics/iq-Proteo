#############################
#
# Pre-SanXoT2: create_id-q   #
#
#############################

# # pwd <- "D:/projects/qProteo/.venv_win"
pwd <- Sys.getenv(c("VIRTUAL_ENV"))
lib_path <- paste0( pwd, "/R/lib")
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
  make_option(c("--control_tag"), type="character", default=NULL,  help="Control tag. Eg. '131'", metavar="character"),
  make_option(c("--first_tag"), type="character", default=NULL, help="First tag. Eg. '126'", metavar="character"),
  make_option(c("--mean_calc"), type="logical", default=TRUE, help="Mean Tag Calculation [default= %default]", metavar="character"),
  make_option(c("--mean_tags"), type="character", default="", help="Mean tags. Eg. '130_C,131,129_C,129_N'", metavar="character"),
  make_option(c("--abs_calc"), type="character", default="both", help="To Absolute Quantification (true = Absolute Quantification, false = Relative Quantification or both = Both) [default= %default]", metavar="character"),  
  make_option(c("--comparatives"), type="integer", default=NULL, help="Number of comparatives within the Experiment. Eg. '10'", metavar="character"),
  make_option(c("--random"), type="logical", default=TRUE, help="Calculate all against all tags [default= %default]", metavar="character"),
  make_option(c("-f", "--filt_orphans"), type="logical", default=TRUE, help="Comet-PTM input: Filter the orphans and No_Mod_Mass [default= %default]", metavar="character"),
  make_option(c("--no_mod_mass"), type="double", default=-0.000163, help="Comet-PTM input: Mass of No modified [default= %default]", metavar="character"),
  make_option(c("-o", "--outfile"), type="character", default=NULL, help="output file", metavar="character")
);
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# BEGIN: IMPORTANT!!!! HARD-CORE inputs!!!
# # PD input:
# opt$in_ident <- "D:/projects/qProteo/test/PESA_omicas/6a_Cohorte_70_Female_V1_V2/TMT_Fraccionamiento/TMT9/PreSanxot2/ID-all.txt"
# opt$in_quant <- "D:/projects/qProteo/test/PESA_omicas/6a_Cohorte_70_Female_V1_V2/TMT_Fraccionamiento/TMT9/PreSanxot2/Q-all.csv"
# opt$tags <- "126,127_N,127_C,128_N,128_C,129_N,129_C,130_N,130_C,131"
# opt$control_tag <- ""
# opt$first_tag <- "126"
# opt$mean_calc = TRUE
# opt$mean_tags <- "126,131"
# opt$abs_calc = "both"
# opt$comparatives <- 10
# opt$random = TRUE
# opt$filt_orphans <- FALSE
# opt$no_mod_mass <- NULL
# opt$outfile <- "D:/projects/qProteo/test/PESA_omicas/6a_Cohorte_70_Female_V1_V2/TMT_Fraccionamiento/TMT9/PreSanxot2/ID-q.txt"
# Comet-PTM input:
# opt$in_ident <- "D:/projects/qProteo/test/Edema_Oxidation_timecourse_Cys_pig/PTMs/TMT1/IsotopCorrection_TargetData_withSequence-massTag.txt"
# opt$in_quant <- "D:/projects/qProteo/test/Edema_Oxidation_timecourse_Cys_pig/PTMs/TMT1/TMT1_Q-all.xls"
# opt$tags <- "126,127_N,127_C,128_N,128_C,129_N,129_C,130_N,130_C,131"
# opt$control_tag <- "126"
# opt$first_tag <- "127_N"
# opt$mean_calc = FALSE
# opt$mean_tags <- ""
# opt$abs_calc = "false"
# opt$comparatives <- 9
# opt$random = FALSE
# opt$filt_orphans <- TRUE
# opt$no_mod_mass <- -0.000163
# opt$outfile <- "D:/projects/qProteo/test/Edema_Oxidation_timecourse_Cys_pig/PTMs/TMT1/PreSanxot2/ID-q.txt"
# END: IMPORTANT!!!! HARD-CORE inputs!!!


if ( is.null(opt$in_ident) || is.null(opt$in_quant) || is.null(opt$outfile) && file.exists(opt$in_ident) && file.exists(opt$in_quant) ) {
  print_help(opt_parser)
  stop("All arguments must be supplied.n", call.=FALSE)
}

# transform some input parameters in array
opt$in_ident <- normalizePath(opt$in_ident, winslash = "/")
opt$in_quant <- normalizePath(opt$in_quant, winslash = "/")
opt$tags <- unlist( strsplit(opt$tags, ",") )
if ( !is.null(opt$mean_tags) ) {opt$mean_tags <- unlist( strsplit(opt$mean_tags, ",") ) }
opt$outfile <- normalizePath(opt$outfile, winslash = "/")
opt$outdir <- dirname(opt$outfile)

print( "input parameters: ")
print( opt )

# calculate the quantification
calculate_IDq <- function(q_all, ID_all, tags, first_tag, comparatives, mean_calc, mean_tags, control_tag, abs_calc, random) {
  
  # # begin: for debugging
  # tags = opt$tags
  # first_tag = opt$first_tag
  # comparatives = opt$comparatives
  # mean_calc = opt$mean_calc
  # mean_tags = opt$mean_tags
  # control_tag = opt$control_tag
  # abs_calc = opt$abs_calc
  # random = opt$random
  # # end: for debugging
  
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
  
  # get the index of columns that will be compared taking into account which it is the first tag.
  # It is obtained combining the number of tags (channels) and the number of comparatives
  # TODO!!! IMPROVE THIS SECTION !!!
  FirstTagIndex=as.numeric(grep(paste0("X",first_tag), colnames(all)))
  CalcIndex=trunc(seq(FirstTagIndex, by=(length(tags)/as.numeric(comparatives)), len = as.numeric(comparatives)),1)
  
  # calculate the mean
  if (mean_calc == TRUE) {
    all$Mean <- rowMeans(all[,paste0("X",mean_tags)], na.rm = TRUE)
    MeanIndex=as.numeric(grep("Mean", colnames(all)))
  }
  
  for (i in CalcIndex) {
    
    ControlIndex=as.numeric(grep(paste0("X",control_tag), colnames(all)))
    
    if (mean_calc == TRUE) {
      all$newcolumn <- log2(all[,i]/all$Mean)
      l <- substring(colnames(all)[i],2)
      colnames(all)[ncol(all)] <- paste0("Xs_",l,"_Mean")
    } else {
      all$newcolumn <- log2(all[,i]/all[,ControlIndex])
      l <- substring(colnames(all)[i],2)
      colnames(all)[ncol(all)] <- paste0("Xs_",l,"_",control_tag)
    }
    
    if (toupper(abs_calc) == "TRUE"){
      all$newcolumn <- all[,c(i)]
      colnames(all)[ncol(all)] <- paste0("Vs_",l,"_ABS")
    }
    
    if (toupper(abs_calc) == "FALSE") {
      if (mean_calc == TRUE) {
        all$newcolumn <- apply(all[,c(i,MeanIndex)], 1, max)
        colnames(all)[ncol(all)] <- paste0("Vs_",l,"_Mean")
      } else {
        all$newcolumn <- apply(all[,c(i,ControlIndex)], 1, max)
        colnames(all)[ncol(all)] <- paste0("Vs_",l,"_",control_tag)
      }
    }
    
    if (toupper(abs_calc) == "BOTH") {
      all$newcolumn <- all[,c(i)]
      colnames(all)[ncol(all)] <- paste0("Vs_",l,"_ABS")
      if (mean_calc == TRUE) {
        all$newcolumn <- apply(all[,c(i,MeanIndex)], 1, max)
        colnames(all)[ncol(all)] <- paste0("Vs_",l,"_Mean")
      } else {
        all$newcolumn <- apply(all[,c(i,ControlIndex)], 1, max)
        colnames(all)[ncol(all)] <- paste0("Vs_",l,"_",control_tag)
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
}

# MAIN ---------

# create workspace
dir.create(opt$outdir, showWarnings = FALSE, recursive = TRUE)

# create the ID-all from the all pRatio results
ID_all <- read.table(file = opt$in_ident, sep = "\t", comment.char = "?",quote = "?", header=TRUE)

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
all <- calculate_IDq(q_all, ID_all, opt$tags, opt$first_tag, opt$comparatives, opt$mean_calc, opt$mean_tags, opt$control_tag, opt$abs_calc, opt$random)

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

