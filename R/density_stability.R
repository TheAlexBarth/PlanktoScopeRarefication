##
# Stability of concentration
# 

# I'm just going to look at core categories
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
