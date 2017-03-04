# This sctripts is used to compare the FA profiles of subjects and that of the template

library(nlme)         # Mixed-effects models
library(ggplot2)      # Plotting tools
library(plyr)
library(dplyr)         # Data manipulation
library(RColorBrewer) # Color tables
library(reshape2)
library(corrgram)
library(psych)
library(coin)
library(gridExtra)

exptDir1 = choose.dir(getwd(), caption = "Select output");
exptDir2 = choose.dir(exptDir1, caption = "Select temp");



# source('funcToTest.R')
################################################################################
# Read in whole-track properties (ex: streamlines) and merge with demographics

# function to read data --------------------------------------------------------
readData <- function(exptDir) {
  trk_props_long = read.table(file.path(exptDir, 'trk_props_long.txt'), header=T)
  
  # Read in length-parameterized track data (ex: FA) and merge with demographics
  trk_data              = read.table(file.path(exptDir, 'trk_data.txt'),
                                     header=T)
  
  trk_data$Point        = factor(trk_data$Point)
  # trk_data[trk_data==0] = NA
  trk_data              = merge(trk_data, trk_props_long)
  # Add a Position column for easier plotting
  trk_data              = ddply(trk_data, c("Tract", "Hemisphere"),
                                transform,
                                Position = (as.numeric(Point)-1) * 100/
                                  (max(as.numeric(Point))-1))
}

# add within group contrast ---------------------------------------------------

# mean value and std value -----------------------------------------------------
groupStat <- function(df) {
  data.frame(y = mean(df), ymin = mean(df) - sd(df), ymax = mean(df) + sd(df))
}
# read data ------------------------------------------------------------------
trk_data <- readData(exptDir1)
trk_data_temp <- readData(exptDir2)



p1 <- ggplot(aes(x = Position, y = FA), data = trk_data)
p1 <- p1 + geom_line(aes(group = ID), alpha = 0.2) + facet_grid(Tract~Hemisphere) + ylim(0, 1) +
  stat_summary(aes(group = 1), fun.data = groupStat, geom = 'smooth', colour = 'blue')
p2 <- p1 + geom_line(data = trk_data_temp, aes(x = Position, y = FA), size = 2, colour = 'red', alpha = 0.5)  + 
  theme_bw() + 
  theme(axis.title.y = element_text(size = 12), text = element_text(size = 12), 
        axis.text = element_text(size = 12)) + ylab('Fractional Anisotrophy')

trk_data_group <- group_by(trk_data, Point, Hemisphere, Tract)
trk_data_mean <- summarise(trk_data_group, mv = mean(FA))

corrCal <- function(dat1, dat2, hemi, trk) {
  corVal <- data.frame(Hemisphere = character(0), Tract = character(0), 
                       corVal = numeric(0))
  for(aa in hemi) {
    for(bb in trk){
      subdat1 <- filter(dat1, Hemisphere == aa & Tract == bb)
      subdat2 <- filter(dat2, Hemisphere == aa & Tract == bb)
      val <- cor.test(subdat1$FA, subdat2$mv)
      corval <- data.frame(Hemisphere = aa, Tract = bb, 
                           corVal = val$estimate)
      corVal <- rbind(corVal, corval)
    }
  }
  return(corVal)
}

corVal <- corrCal(trk_data_temp, trk_data_mean, c('L', 'R'), 
                  c('CST', 'CING', 'UNC'))
write.table(corVal, file = 'corValFile.csv', append = T)
#
#
# trk_data_sim <- dlply(trk_data, c('ID'), FDcalc_vec)
# trk_data_sim_mean <- vapply(trk_data_sim, mean, as.numeric(0))




