##
# Rarefication
##
# This script makes rarefication curves for planktoscope machines
# Suggested methodology: Take a large number of images (500) from a local sample
# Sort into categories in ecotaxa to the best of ability
# You can edit category names at the top based on interest in taxonomic interest
rm(list = ls())
source("./R/helpers.R")
load("./Data/pklist.rda") #this is a list of my ecotaxa tsvs for several projects

#Load in ecotaxa export tsv here
og_data <- pklist$BS_B200 #i'm using rda objects from ealier wrangling

#likely need to edit based off unique(data$object_annotation_category)
#edit all the names to remove from the data (artefacts & detritus)
det_names <- c("fiber<detritus","artefact","detritus-green","badfocus<artefact",
               "dark<detritus",'green-fragments',"detritus","detritus-dark",
               "light<detritus","duplicate",'temp circle',"tail<Crustacea","molt")

#enter specific data
collection_vol <- gal_L(10) * 1000 #ml
conc_vol <- 250 #ml

#calc necs columns
dil_factor <- collection_vol / conc_vol #concentrated
img_vol <- unique(og_data$acq_imaged_volume / og_data$acq_nb_frame) *dil_factor #this should be length ==1
og_data$img_id <- unlist(lapply(og_data$object_id,get_img))
trim_dat <- og_data[!(og_data$object_annotation_category %in% det_names),] #remove detritus images

##
# Set up image sub_sampling vector
nb_empty <- unique(trim_dat$acq_nb_frame) - length(unique(trim_dat$img_id)) #nb empty frames
imgs <- c(unique(trim_dat$img_id),rep("none",nb_empty)) #frames to sample from


##
# Calculate species richness over vol_sampled
iter <- 9999 #iteration length

mean_sp <- rep(NA,unique(trim_dat$acq_nb_frame)) #mean richness
sd_sp <- rep(NA,unique(trim_dat$acq_nb_frame)) #sd richness

for(i in 1:unique(trim_dat$acq_nb_frame)){
  sp_count <- rep(NA,iter)
  for(l in 1:iter){
    sample_img <- sample(imgs,i) #sample several images
    taxa <- trim_dat$object_annotation_category[trim_dat$img_id %in% sample_img]
    sp_count[l] <- length(unique(taxa))
    print(paste("Processing ",i,"/",unique(trim_dat$acq_nb_frame),
                " ",round((l/iter)*100,1),"%"," done",sep = ""))
  }
  mean_sp[i] <- mean(sp_count)
  sd_sp[i] <- sd(sp_count)
}

vol_sampled <- 1:unique(trim_dat$acq_nb_frame) * img_vol
r_curve <- data.frame(mean_sp = mean_sp,
                      sd_sp = sd_sp,
                      vol_sampled = vol_sampled)

#quick plot if you like
rich_plot(r_curve)

#Save data if you like
BS_B200_richness <- r_curve #rename
save(BS_B200_richness,file = "./Data/BS_B200_richness.rda")


