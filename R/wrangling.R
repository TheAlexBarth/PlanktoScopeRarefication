##
# Data Wrangling
##

#set up
source("./R/helpers.R")
#pull in initial export
raw <- read_tsv("~/Data/PlanktoScope/NI_PScomp_export20220128.tsv")


# Need to correct the metadata, there seems to be an issue with instrument naming
# I'm going to relate vignettes in the annotated export file to the original tsv
file_path <- "~/Data/PlanktoScope/PSFixing"
og_files <- dir(file_path)
og_list <- read_multiple_tsv(paste(file_path,og_files,sep = "/"))

# need to find which files match which instrument
raw$inst_config <- rep(NA,nrow(raw))
for(i in 1:nrow(raw)){
  finder <- rep(NA,length(og_list))
  for(l in 1:length(og_list)){
    finder[l] <- raw$object_id[i] %in% og_list[[l]]$object_id
  }
  raw$inst_config[i] <- sub(".tsv","",og_files)[which(finder)]
}


#split into multiple files
pklist <- split(raw,f = raw$inst_config)
save(pklist, file = "./Data/pklist.rda")
