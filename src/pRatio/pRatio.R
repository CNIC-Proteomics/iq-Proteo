################################################################################################################

# Install packages if they don't exit

################################################################################################################

lib_path <- Sys.getenv(c("IQPROTEO_R_LIB"))
.libPaths( lib_path )

# list.of.packages <- c("optparse", "RSQLite", "readr", "stringi", "plyr", "Peptides", "XML")
# new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
# if(length(new.packages)) install.packages(new.packages, repos="http://cran.us.r-project.org", lib=lib_path)

# Libraries

library("optparse")
library("RSQLite")
library("readr")
library("stringi")
library("plyr")
library("Peptides")
library("XML")

################################################################################################################

# Get Params

################################################################################################################

# get input parameters
option_list = list(
  make_option(c("-i", "--msf_dir"), type="character", default=NULL, help="input directory (per experiment) with MSF files", metavar="character"),
  make_option(c("-r", "--regex"), type="character", default=NULL, help="Regular expression that select specific MSF files parsing the file name. By default, we take all files", metavar="character"),
  make_option(c("-m", "--mod_file"), type="character", default="modifications.xml", help="XML input file with modifications", metavar="character"),
  make_option(c("-t", "--threshold"), type="integer", default=15, help="threshold of delta mass in ppm [default= %default]", metavar="character"),
  make_option(c("-d", "--delta_mass"), type="integer", default=5, help="number of jumps: 1,3 or 5 [default= %default]", metavar="character"),
  make_option(c("-a", "--tag_mass"), type="double", default=229.162932, help="mass for the tag's [default= %default]", metavar="character"),
  make_option(c("-l", "--lab_decoy"), type="character", default="DECOY_", help="label of decoy sequences in the db file [default= %default]", metavar="character"),
  make_option(c("-o", "--outfile"), type="character", default=NULL, help="output file with the pRatio's", metavar="character")
);
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if ( is.null(opt$msf_dir) || is.null(opt$outfile) ) {
  print_help(opt_parser)
  stop("All arguments must be supplied.n", call.=FALSE)
}

# BEGIN: IMPORTANT!!!! HARD-CORE inputs!!!
# opt$msf_dir = "D:/projects/iq-Proteo/src/pRatio/TMT1"
# opt$mod_file = "D:/projects/iq-Proteo/src/pRatio/modifications.xml"
# opt$outfile = "D:/projects/iq-Proteo/src/pRatio/TMT1/ID-all.txt"
# opt$threshold = 15
# opt$delta_mass = 5
# opt$tag_mass = 229.162932
# opt$lab_decoy = "_INV_"
# END: IMPORTANT!!!! HARD-CORE inputs!!!

# assign new variable names
deltaMassThreshold = opt$threshold
deltaMassAreas = opt$delta_mass
tagMass = opt$tag_mass
tagDecoy = opt$lab_decoy

print( "input parameters: ")
print( opt )

################################################################################################################

# Local functions

################################################################################################################

# prepare DATA: mods & prots
ptmAnnotation <- function(x)
{
  pep<-x[1,]$Sequence
  b<-0
  p<-""
  modNum<-1
  modMass<-0
  for (i in x$Position)
  {
    p <- stri_flatten(c(p,substr(pep,b,i+1),"[",x[modNum,]$DeltaMass,"]"),collapse="")
    modMass<-modMass + x[modNum,]$DeltaMass
    #p <- paste(p,substr(pep,b,i+1),"[",x[modNum,]$DeltaMass,"]",sep="")
    b <- i+2
    modNum <- modNum+1
  }
  #p <- paste(p,substr(pep,b,nchar(pep)),sep="")
  p <- stri_flatten(c(p,substr(pep,b,nchar(pep))),collapse="")
  return(c(p,modMass))
}

# filter by deltaMass
filterDeltaMass <- function(x, deltaMassThreshold, deltaMassAreas)
{
  TheoreticalModTag=x[1]
  Mass=x[2]
  ScoreValue=x[3]
  jump1_ppm = abs(TheoreticalModTag - Mass) / TheoreticalModTag * 1e6
  if (jump1_ppm >= deltaMassThreshold)
  {
    if (deltaMassAreas <= 1) { return(0.01) } # jump 1 >= threshold
    else 
    {
      MassCorr <- Mass - 1.0033
      jump23_ppm = abs(TheoreticalModTag - MassCorr) / TheoreticalModTag * 1e6
      if (jump23_ppm >= deltaMassThreshold)
      {  
        if (deltaMassAreas <= 3) { return(0.01) } # jump 23 >= threshold
        else
        {
          MassCorr2 <- Mass - 1.0033
          jump45_ppm = abs(TheoreticalModTag - MassCorr2) / TheoreticalModTag * 1e6
          if (jump45_ppm >= deltaMassThreshold) {return (0.01)} # jump 45 >= threshold
          else {return (ScoreValue)} # jump 45 < threshold
        }
      }
      else
      {
        return (ScoreValue) # jump 23 < threshold
      }
    }
  }
  else
  {
    return(ScoreValue) # jump 1 < threshold
  }
}

# replace modifications to symbols (output to tmp)
parsingMod <- function(weight, symbol) {
  resPratio$Sequence <<- gsub( paste0('\\[',weight,'\\]'), symbol, resPratio$Sequence) # global access
}


################################################################################################################

# Main function

################################################################################################################

# parse the modifications xml file
mod_xml <- xmlParse(opt$mod_file)
modifications <- xmlToDataFrame(nodes = xmlChildren(xmlRoot(mod_xml)[["modifSet"]]) )

# save the all ID_all
id_all <- NULL

# get the list of MSF files from the two ways from the given directory
# we take into account the regular expression for the file names
print("get the list of MSF files from the two ways from the given directory")
msf_files <- list.files(path = opt$msf_dir, pattern="*.msf$", full.names = TRUE, recursive = TRUE)
if ( !is.null(opt$regex) ) {
  msf_files <- grep(opt$regex, msf_files, perl=TRUE, value = TRUE)
}
print(msf_files)
if ( length(msf_files) == 0 ) {
  stop("Empty list of MSF files")
} else {

  # Create pRatio for all files
  print("Create pRatio for all files")  
  for (msf_file in msf_files) {
    print(paste0("get pRatio for the file: ", msf_file))
    
    # create queries for the MSF file
    db=dbConnect(SQLite(), dbname=msf_file)
    
    queryMain = "select 
    p.peptideid, 
    fi.filename, 
    sh.firstscan, 
    sh.lastscan, 
    sh.charge, 
    p.sequence,
    sh.mass,  
    ps.scorevalue,  
    sh.retentiontime,  
    p.searchenginerank, 
    p.deltascore  
    from peptides p, 
    peptideScores ps, 
    spectrumHeaders sh, 
    massPeaks mp, 
    workFlowInputFiles fi, 
    processingNodeScores scoreNames 
    where p.peptideid = ps.peptideid 
    and sh.spectrumid = p.spectrumid 
    and (fi.fileid = mp.fileid or mp.fileid = -1) 
    and mp.masspeakid = sh.masspeakid 
    and scoreNames.scoreid = ps.scoreid 
    and scoreNames.ScoreName = 'Xcorr'  
    and p.searchenginerank = 1   
    and ps.scorevalue > 1.5
    order by 
    fi.filename desc,  
    sh.firstscan asc, 
    sh.lastscan asc,  
    sh.charge asc,  
    ps.scorevalue desc" 
    
    data=dbGetQuery(conn = db, queryMain)
    
    queryModifications = "select 
    p.peptideid, 
    paam.aminoacidmodificationid, 
    paam.position,  
    p.sequence,  
    aam.modificationname,  
    aam.deltamass   
    from peptides p, 
    peptideScores ps, 
    spectrumHeaders sh, 
    peptidesaminoacidmodifications paam, 
    aminoacidmodifications aam 
    where p.peptideid = paam.peptideid 
    and sh.spectrumid = p.spectrumid 
    and p.peptideid = ps.peptideid 
    and aam.aminoacidmodificationid = paam.aminoacidmodificationid 
    and p.searchenginerank = 1 
    and ps.scorevalue > 1.5
    order by p.peptideid ASC, paam.position ASC"
    
    dataMod=dbGetQuery(conn = db, queryModifications)
    
    queryProteinInfo = "select 
    pq.peptideid, 
    p.sequence, 
    pq.proteinid,  
    q.description  
    from peptidesProteins pq, 
    spectrumHeaders sh, 
    peptides p, 
    peptideScores ps, 
    proteinAnnotations q 
    where pq.peptideid = p.peptideid 
    and p.peptideid = ps.peptideid 
    and pq.proteinid = q.proteinid 
    and sh.spectrumid = p.spectrumid 
    and p.searchenginerank = 1 
    and ps.scorevalue > 1.5
    order by pq.peptideid asc"
    
    dataProt=dbGetQuery(conn = db, queryProteinInfo)      
    
    
    ## prepare DATA: mods & prots
    dataModAnnotation <- ddply(dataMod,.(PeptideID),ptmAnnotation)
    
    colnames(dataModAnnotation) <- c("PeptideID","Sequence","modMass")
    
    dataModAnnotation$modMass <- as.numeric(dataModAnnotation$modMass)
    
    # mix unmodified and modified
    dataModTmp <- merge(unique(data[,c("PeptideID","Sequence")]),dataModAnnotation,by = "PeptideID",all.x=TRUE)
    dataModTmp[is.na(dataModTmp["Sequence.y"]),"Sequence.y"] <- dataModTmp[is.na(dataModTmp["Sequence.y"]),"Sequence.x"]
    dataModAll <- dataModTmp[,c("PeptideID","Sequence.y","modMass")]
    colnames(dataModAll) <- c("PeptideID","SequenceMod","modMass")
    
    redundances <- aggregate(Description ~ PeptideID, data=dataProt, paste, collapse = " -- ")
    colnames(redundances) <- c("PeptideID","Redundances")
    dataProt.u <- dataProt[!duplicated(dataProt["PeptideID"]),]
    peptideProt <- merge(dataProt.u[,c("PeptideID","Description")], redundances, by="PeptideID", all.x=TRUE)
    
    #*****
    dataAll <- cbind(data, dataModAll$"SequenceMod",  dataModAll$"modMass", peptideProt[ , -which(names(peptideProt) %in% c("PeptideID"))])
    colnames(dataAll) <- c("PeptideID","FileName","FirstScan","LastScan","Charge","Sequence","Mass","ScoreValue","RetentionTime","SearchEngineRank","DeltaScore","SequenceMod","modMass","Description","Redundances")
    
    ## Calculate theoretical mass
    dataAll[is.na(dataAll[,"modMass"]),]$modMass <- 0
    # Be careful!!! The following line of code could print a Warning messages:Sequence 1 has unrecognized amino acid types. Output value might be wrong calculated 
    dataAll <- cbind(dataAll,as.data.frame(unlist(lapply(dataAll[,c("Sequence")], mw, monoisotopic=TRUE))))
    names(dataAll)[length(names(dataAll))]<-"Theoretical" 
    dataAll$Theoretical <- dataAll$Theoretical + 1.00727647
    dataAll <- cbind(dataAll, dataAll$Theoretical + dataAll$modMass + tagMass)
    names(dataAll)[length(names(dataAll))]<-"TheoreticalModTag" 
    dataAll <- cbind(dataAll, abs(dataAll$Mass - dataAll$Theoretical - dataAll$modMass - tagMass) / dataAll$Mass * 1e6)
    names(dataAll)[length(names(dataAll))]<-"deltaMassTargetppm" 
    
    ## Decoy tagging
    isDecoy <- rep(0, dim(dataAll)[1])
    isTarget <- rep(1, dim(dataAll)[1])
    protein <- dataAll[,'Description']
    index <- grep(tagDecoy,protein,fixed=TRUE)
    isDecoy[index] <- 1
    isTarget[index] <- 0
    dataAll <- cbind(dataAll,isDecoy,isTarget)
    
    ## filter by deltaMass
    jump1ScoreValue <-as.data.frame(unlist(apply(dataAll[,c("TheoreticalModTag","Mass","ScoreValue")], 1, filterDeltaMass, deltaMassThreshold=deltaMassThreshold, deltaMassAreas=deltaMassAreas)))
    colnames(jump1ScoreValue) <- "ScoreValueAfterJUMP"
    dataAll$ScoreValue<-jump1ScoreValue$ScoreValueAfterJUMP #Assign the calculated scored after being modified and
    #assign to the column ScoreValue
    
    ## Add xcorr_c
    n = dim(dataAll)[1]
    
    xcorr_c <- function(x) {
      r=1
      if(as.numeric(x[1])>2) {r=1.22}
      xcorr_c = log((as.numeric(x[2]))/r)/log(2*nchar(as.character(x[3])))
      return (xcorr_c)
    }
    
    dataAll <- cbind(dataAll,apply(dataAll[,c("Charge","ScoreValue","Sequence")], 1, xcorr_c))
    
    colnames(dataAll)[ncol(dataAll)] <- "xcorr_c"
    
    # sort by xcorr_c
    #dataAll <- dataAll[order(decreasing = TRUE,dataAll$xcorr_c),]
    ##dataAll <- dataAll[order(decreasing = TRUE,dataAll$ScoreValue),]
    #tmp <- cbind(dataAll[, "xcorr_c"], dataAll[, "isDecoy"])
    ##tmp <- cbind(dataAll[, "ScoreValue"], dataAll[, "isDecoy"])
    #FP <- cumsum(tmp[, 2])
    #tmp <- cbind(tmp, FP)
    #xcorr_cP <- unlist(lapply(1:n, function(x) (tmp[x, 'FP'])/n))
    #dataAll <- cbind(dataAll, xcorr_cP)
    
    ### FDR ScoreValue
    
    dataAll <- dataAll[order(decreasing = TRUE,dataAll$ScoreValue),]
    tmp <- cbind(dataAll[, "ScoreValue"], dataAll[, "isDecoy"], dataAll[, "isTarget"])
    FP <- cumsum(tmp[, 2])
    TP <- cumsum(tmp[, 3])
    tmp <- cbind(tmp, FP, TP)
    xcorr_FDR <- unlist(lapply(1:dim(dataAll)[1], function(x) (tmp[x, 'FP'])/(tmp[x, 'TP'])))
    dataAll <- cbind(dataAll, tmp, xcorr_FDR)
    xcorr_FDRa <- unlist(lapply(1:dim(dataAll)[1], function(x) max(dataAll[1:x,"xcorr_FDR"])))
    dataAll <- cbind(dataAll, xcorr_FDRa)
    
    ### FDR CALC
    dataAll <- dataAll[order(decreasing = TRUE,dataAll$xcorr_c),]
    tmp <- cbind(dataAll[, "xcorr_c"], dataAll[, "isDecoy"], dataAll[, "isTarget"])
    FP <- cumsum(tmp[, 2])
    TP <- cumsum(tmp[, 3])
    tmp <- cbind(tmp, FP, TP)
    xcorr_c_FDR <- unlist(lapply(1:dim(dataAll)[1], function(x) (tmp[x, 'FP'])/(tmp[x, 'TP'])))
    dataAll <- cbind(dataAll, tmp, xcorr_c_FDR)
    xcorr_c_FDRa <- unlist(lapply(1:dim(dataAll)[1], function(x) max(dataAll[1:x,"xcorr_c_FDR"])))
    dataAll <- cbind(dataAll, xcorr_c_FDRa)
    
    res <- dataAll[dataAll$xcorr_c_FDR < 0.01 & dataAll$isTarget == 1,]  
    #res <- dataAll[dataAll$xcorr_c_FDR < 0.01,]            
    
    fileName <- strsplit(data[1,"FileName"], fixed = TRUE, split = "\\")[[1]][length(strsplit(data[1,"FileName"], fixed = TRUE, split = "\\")[[1]])]
    pRatio <- "NA"; pI <- "NA"; Xcorr1Original <- "NA"; Xcorr2Search <- "NA"; Sp <- "NA"; SpRank <- "NA"; ProteinsWithPeptide <- "NA"
    
    resPratio <- cbind(fileName,fileName,res[,c("FirstScan","LastScan","Charge")],pRatio,res[,c("xcorr_c_FDR","Description","SequenceMod")],pI,res[,c("Mass","xcorr_c")],Xcorr1Original,Xcorr2Search,res[,"DeltaScore"],Sp,SpRank,ProteinsWithPeptide,res[,"Redundances"])
    
    colnames(resPratio) <- c("FileName","RAWFile","FirstScan","LastScan","Charge","pRatio","FDR","FASTAProteinDescription","Sequence","pI","PrecursorMass","Xcorr1Search","Xcorr1Original","Xcorr2Search","DeltaCn","Sp","SpRank","ProteinsWithPeptide","Redundances")
    
    #SIMPLYFIED
    resPratio <- resPratio[,c("FileName","RAWFile","FirstScan","LastScan","Charge","Sequence","FASTAProteinDescription","Xcorr1Search","FDR","Redundances")]
    
    # replace modifications to symbols (output to tmp)
    tmp <- apply(modifications[,c('weight', 'symbol')], 1, function(x) parsingMod(x[1],x[2]))
    
    # write tmp file with the pRatios
    outdir <- dirname(msf_file)
    fname <- sub(pattern = "(.*)\\..*$", replacement = "\\1", basename(msf_file))
    outfile <- paste0(outdir, "/", fname, ".pratio.txt")
    write.table(resPratio,file = outfile,col.names = TRUE, row.names = FALSE,sep="\t", quote = FALSE)
    
    # join the pRatio results for all MSF files in the given directory
    id_all <- rbind(id_all, resPratio)
  
  } # end-loop files
} # end-if files


# transform some input parameters
opt$outdir <- dirname(opt$outfile)

# create workspace
dir.create(opt$outdir, showWarnings = FALSE, recursive = TRUE)

# write output file
print("write output file")
write_tsv(id_all, opt$outfile)

