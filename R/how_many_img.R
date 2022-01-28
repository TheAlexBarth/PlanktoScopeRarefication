##
# Caculation for what you need to sample raw and how many images
source("./R/helpers.R")

goal_img_vol <- 200 #mL of goal imaged volume 
conc_vol <- 250 #mL concentration container

col_vol <- unlist(lapply(seq(5,20,5),gal_L)) * 1000
dil_fact <- col_vol / conc_vol
flow_cell <- "200"
indv_vol <- switch(flow_cell,
                   "200" = 4.15*3.14*0.2 * 0.001,
                   "600" = 4.15*3.14*0.6 * 0.001,
                   stop("Only use '200' or '600'"))

needed_img <- goal_img_vol / (indv_vol*dil_fact)
