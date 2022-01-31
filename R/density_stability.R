##
# Stability of concentration
# 

# I'm just going to look at core categories
rm(list = ls())
source("./R/helpers.R")
load("./Data/pklist.rda") #this is a list of my ecotaxa tsvs for several projects

#Load in ecotaxa export tsv here
og_data <- pklist$BS_B200 #i'm using rda objects from ealier wrangling


#enter specific data
collection_vol <- gal_L(15) * 1000 #ml
conc_vol <- 250 #ml

#calc necs columns
dil_factor <- collection_vol / conc_vol #concentrated
img_vol <- unique(og_data$acq_imaged_volume / og_data$acq_nb_frame) *dil_factor #this should be length ==1
og_data$img_id <- unlist(lapply(og_data$object_id,get_img))


#likely need to edit based off unique(data$object_annotation_category)
#edit all the names to remove from the data (artefacts & detritus)
det_names <- c("fiber<detritus","artefact","detritus-green","badfocus<artefact",
               "dark<detritus",'green-fragments',"detritus","detritus-dark",
               "light<detritus","duplicate",'temp circle',"tail<Crustacea","molt")
diatom_names <- c("Chaetoceros chain","Skeletonema costatum","Skeletonema","Chaetoceros pendulus",
                  "Chaetoceros single","Bacillariophyta","Thalassionema","Bacillariophyceae",
                  "Rhizosolenia","Navicula","Cylindrotheca","Lioloma","Asterionellopsis","centric",
                  "Rhizosolenia imbricata","Pleurosigma","Bacillaria paxillifera","Hemiaulus",
                  "pennate<Bacillariophyta","Guinardia striata","Eucampia","Coscinodiscus",
                  "Guinardia delicatula","Corethron")
Mesozoo_names <- c("Oithona","Calanoida","copepodite<Oithonidae","Cladocera")
mz_dino_names <- c("Dinophysis","Ciliophora","Gyrosigma","Myrionecta rubra","Tintinnida",
                   "Myzozoa","Mesodinium","Rotifera","Eutintinnus","Protoperidinium",
                   "Prorocentrum sp.","Cochlodinium","Acantharea","multiple<other","other<living")

og_data$broad_cats <- rep(NA,nrow(og_data))


##
# Reassign categories to the broad names
og_data$broad_cats[which(og_data$object_annotation_category %in% det_names)] <- "detritus"
og_data$broad_cats[which(og_data$object_annotation_category %in% diatom_names)] <- "diatom"
og_data$broad_cats[which(og_data$object_annotation_category %in% Mesozoo_names)] <- "mesozoo"
og_data$broad_cats[which(og_data$object_annotation_category %in% mz_dino_names)] <- "mz"

denDf <- data.frame(vol_sampled = img_vol * 1:unique(og_data$acq_nb_frame),
                    diatom = rep(NA, unique(og_data$acq_nb_frame)),
                    sd_diatom = rep(NA, unique(og_data$acq_nb_frame)),
                    meso = rep(NA, unique(og_data$acq_nb_frame)),
                    sd_meso = rep(NA, unique(og_data$acq_nb_frame)),
                    mz_dino = rep(NA, unique(og_data$acq_nb_frame)),
                    sd_mzdino = rep(NA, unique(og_data$acq_nb_frame)))

# iterate and calculate
iter <-  9999
#vector to set up images
img_names <- c(unique(og_data$img_id),rep("blank",
                                          unique(og_data$acq_nb_frame) - length(unique(og_data$img_id)))) 
for(r in 1:nrow(denDf)){
  diatom_storage <-  rep(NA,iter) #storage vectors
  meso_storage <-  rep(NA, iter)
  mz_storage <-  rep(NA,iter)
  vol <- denDf$vol_sampled[r]
  for(i in 1:iter){
    img_sample <- sample(img_names,r,replace = T) #sub sample images
    sampled_cats <- og_data$broad_cats[which(og_data$img_id %in% img_sample)] #get cat names
    diatom_storage[i] <- length(which(sampled_cats == "diatom"))
    meso_storage[i] <- length(which(sampled_cats == "mesozoo"))
    mz_storage[i] <- length(which(sampled_cats == "mz"))
    print(paste0("Processing ",r,"/",nrow(denDf),
                " ",round((i/iter)*100,3),"%"," done"))
  }
  diatom_conc <- diatom_storage / vol #calc indv/mL
  meso_conc <- meso_storage / vol
  mz_conc <- mz_storage / vol
  denDf$diatom[r] <- sum(diatom_conc)/length(diatom_conc) #it is faster primitively
  denDf$sd_diatom[r] <- sum(abs(diatom_conc - denDf$diatom[r])) / length(diatom_conc)
  denDf$meso[r] <- sum(meso_conc)/length(meso_conc)
  denDf$sd_meso[r] <- sum(abs(meso_conc - denDf$meso[r])) / length(meso_conc)
  denDf$mz_dino[r] <- sum(mz_conc)/length(mz_conc)
  denDf$sd_mzdino[r] <- sum(abs(mz_conc - denDf$mz_dino[r])) / length(mz_conc)
}

# convert indv/mL to indv/L
denDf$diatom <- denDf$diatom * 1000
denDf$sd_diatom <- denDf$sd_diatom * 1000
denDf$meso <- denDf$meso * 1000
denDf$sd_meso <- denDf$sd_meso * 1000
denDf$mz_dino <- denDf$mz_dino * 1000
denDf$sd_mzdino <- denDf$sd_mzdino * 1000

# rename
BS_B200_den <- denDf
save(BS_B200_den, file = "./Data/BS_B200_den.rda")

