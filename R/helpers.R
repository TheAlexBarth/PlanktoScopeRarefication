## Helper functions

#' read_multiple_tsv
#' 
#' @param files a vect of files to read in
read_multiple_tsv <- function(files){
  require(readr)
  outList <- vector(mode = 'list',length = length(files))
  for(l in 1:length(outList)){
    outList[[l]] <- invisible(read_tsv(files[l]))
  }
  names(outList) <- files
  return(outList)
}

#' get_img
#' 
#' @param x input
get_img <- function(x){
  paste0(strsplit(x,"")[[1]][1:15],collapse = "")
}

#' gal_L
#' 
#' @param gal
gal_L <- function(gal){
  return(gal * 3.78541)
}

#' rich_plot a quick base r plot for richness data
#' 
#' @param r_curve the r_curve data frame
rich_plot <- function(r_curve){
  df <- r_curve
  rplot <- plot(df$mean_sp~df$vol_sampled, col = "black",pch = 20,
                xlab = "Vol Sampled [mL]",ylab = "Spp. Richness")
  rerror <- arrows(df$vol_sampled,df$mean_sp-df$sd_sp,
         df$vol_sampled,df$mean_sp+df$sd_sp,
         length = 0.05,angle = 90,col = rgb(red = 0,green = 1,blue = 0,alpha = 0.5))
  return(c(rplot,rerror))

}