#############################
#
# Pre-SanXoT2: create_q-all   #
#
#############################

# load libraries
library("RSQLite")
library("optparse")
library("readr")

# get input parameters
option_list = list(
  make_option(c("-i", "--msf_dir"), type="character", default=NULL, help="input directory (per experiment) with MSF files", metavar="character"),
  make_option(c("-r", "--regex"), type="character", default=NULL, help="Regular expression that select specific MSF files parsing the file name. By default, we take all files", metavar="character"),
  make_option(c("-s", "--pd_version"), type="integer", default=2, help="Version of ProteinDiscover [default= %default]", metavar="character"),
  make_option(c("-d", "--daemon"), type="logical", default=TRUE, help="Daemon used [default= %default]", metavar="character"),
  make_option(c("-t", "--tags"), type="character", default=NULL, help="Tags Used in the Experiment. Eg. '126,127_N,127_C,128_N,128_C,129_N,129_C,130_N,130_C,131'", metavar="character"),
  make_option(c("-o", "--outfile"), type="character", default=NULL, help="output file", metavar="character")
);
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# BEGIN: IMPORTANT!!!! HARD-CORE inputs!!!
# opt$msf_dir <- "D:/projects/qProteo/test/PESA_omicas/6a_Cohorte_70_Female_V1_V2/TMT_Fraccionamiento/TMT9"
# opt$pd_version <- 2
# opt$daemon <- TRUE
# opt$tags <- "126,127_N,127_C,128_N,128_C,129_N,129_C,130_N,130_C,131"
# opt$outfile <- "D:/projects/qProteo/test/PESA_omicas/6a_Cohorte_70_Female_V1_V2/TMT_Fraccionamiento/TMT9/PreSanxot2/Q-all.csv"
# END: IMPORTANT!!!! HARD-CORE inputs!!!

if ( is.null(opt$msf_dir) || is.null(opt$tags) || is.null(opt$outfile) ){
  print_help(opt_parser)
  stop("All arguments must be supplied.n", call.=FALSE)
}

# transform some input parameters
opt$msf_dir <- normalizePath(opt$msf_dir, winslash = "/")
opt$tags <- unlist( strsplit(opt$tags, ",") )
opt$outfile <- normalizePath(opt$outfile, winslash = "/")
opt$outdir <- dirname(opt$outfile)

print( "input parameters: ")
print( opt )

# create workspace if not exit
dir.create(opt$outdir, showWarnings = FALSE, recursive = TRUE)

# get the list of MSF files from the two ways from the given directory
# we take into account the regular expression for the file names
print("extract the MSF files")
db = NULL
q_all <- NULL
msf_files <- list.files(path = opt$msf_dir, pattern="*.msf$", full.names = TRUE, recursive = TRUE)
if ( !is.null(opt$regex) ) {
  msf_files <- grep(opt$regex, msf_files, perl=TRUE, value = TRUE)
}
print(msf_files)
for (msf_file in msf_files) {
  print( paste0("extract msf_file: ", msf_file) )
  db = dbConnect(SQLite(), dbname = msf_file)
  if(opt$pd_version == 2) {
    data=dbGetQuery(conn = db,
                    "SELECT [SpectrumHeaders].[FirstScan],
                    [ReporterIonQuanResults].[Mass] AS [Mass2],
                    [ReporterIonQuanResults].[Height] AS [Height1],
                    [SpectrumHeaders].[RetentionTime],
                    [ReporterIonQuanResults].[QuanChannelID],
                    [MassPeaks].[MassPeakID],
                    [Workflows].[WorkflowName] AS [FileName]
                    FROM [ReporterIonQuanResults]
                    INNER JOIN [SpectrumHeaders] ON [ReporterIonQuanResults].[SpectrumID] =
                    [SpectrumHeaders].[SpectrumID]
                    INNER JOIN [MassPeaks] ON [MassPeaks].[MassPeakID] =
                    [SpectrumHeaders].[MassPeakID]
                    INNER JOIN [WorkflowInputFiles] ON [MassPeaks].[FileID] =
                    [WorkflowInputFiles].[FileID]
                    INNER JOIN [Workflows] ON [WorkflowInputFiles].[WorkflowID] =
                    [Workflows].[WorkflowID]
                    WHERE [ReporterIonQuanResults].[Mass] > 0")
  } else {
    data=dbGetQuery(conn = db,
                    "SELECT [SpectrumHeaders].[FirstScan],
                    [ReporterIonQuanResults].[Mass] AS [Mass2],
                    [ReporterIonQuanResults].[Height] AS [Height1],
                    [SpectrumHeaders].[RetentionTime],
                    [ReporterIonQuanResults].[QuanChannelID],
                    [MassPeaks].[MassPeakID],
                    [WorkflowInfo].[WorkflowName] AS [FileName]
                    FROM [ReporterIonQuanResults]
                    INNER JOIN [SpectrumHeaders] ON [ReporterIonQuanResults].[SpectrumID] =
                    [SpectrumHeaders].[SpectrumID]
                    INNER JOIN [MassPeaks] ON [MassPeaks].[MassPeakID] =
                    [SpectrumHeaders].[MassPeakID]
                    INNER JOIN [FileInfos] ON [MassPeaks].[FileID] = [FileInfos].[FileID],
                    [WorkflowInfo]
                    WHERE [ReporterIonQuanResults].[Mass] > 0")
  }
  q_all <- rbind(q_all, data)
}
if ( !is.null(db) ) { dbDisconnect(db) }

print("change the dataframe depending the PD")
if (opt$daemon == TRUE | opt$pd_version == 2) {  
  q_all$FileName<-paste(q_all$FileName,".raw",sep="")
} else {
  q_all$FileName<-substring(q_all$FileName,1,(nchar(as.character(q_all$FileName))-4))
  q_all$FileName<-paste(q_all$FileName,".raw",sep="")
}

print("print MSF results in text file")
outfile <- paste0(opt$outdir,"/Q-all.txt")
print(outfile)
write_tsv(q_all, outfile)

print("transpose the MSF values based on the channels (tags)")
y <- q_all
q_all <- data.frame()
x <- sort( unique( y[,"QuanChannelID"]) )
for (i in sort( unique( y[,"QuanChannelID"]) ) ) {
  TMT<-y[,"QuanChannelID",drop=FALSE]==i
  z<-y[TMT,][,,drop=FALSE]
  TMTgood<-complete.cases(z)	#posicion de NaN
  a<-z[TMTgood,][,,drop=FALSE]
  c<-a[,c("FirstScan","Height1","FileName")]
  colnames(c)=c("FirstScan",i,"FileName")
  if ( nrow(q_all)==0 ) {
    q_all <- c
  } else {
    q_all <- merge(q_all,c, all=TRUE)
  }
}

print("assign the tags to the number of channel")
colnames_tags=c("FirstScan","FileName")
TagsUsed=paste0("X",opt$tags)
colnames_tags=append(colnames_tags, TagsUsed)
colnames(q_all)=colnames_tags
colnames_tags=c("Raw_FirstScan")
colnames_tags=append(colnames_tags, TagsUsed)

print("create file")
write_csv(q_all, opt$outfile)
