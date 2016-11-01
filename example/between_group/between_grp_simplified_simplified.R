# This sctripts just used to contrast the correspond between
# registered tracts and real tracts.
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

exptDir1 = choose.dir(getwd(), caption = "Select output from sym temp...");
exptDir2 = choose.dir(exptDir1, caption = "Select output from asym temp...");



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
FDcalc <- function(df1, df2) {
  FDvalue <- sum(abs(df1$FA-df2$FA))/nrow(df1)
}

df_FD_calc <- function(df) {
  df_L <- filter(df, Hemisphere == "L")
  df_R <- filter(df, Hemisphere == "R")

  data.frame(ID = unique(df$ID), Tract = unique(df$Tract), FD = FDcalc(df_L, df_R))
}

# mean value and std value -----------------------------------------------------
groupStat <- function(df) {
  data.frame(y = mean(df), ymin = mean(df) - sd(df), ymax = mean(df) + sd(df))
}
# read data ------------------------------------------------------------------
trk_data_sym  <- readData(exptDir1)
trk_data_asym <- readData(exptDir2)

trk_data_sym_FD  <- ddply(trk_data_sym, c('ID', 'Tract'), df_FD_calc)
trk_data_asym_FD <- ddply(trk_data_asym, c('ID', 'Tract'), df_FD_calc)

p1 <- ggplot(aes(x = Position, y = FA), data = trk_data_sym)
p1 <- p1 + geom_line(aes(group = ID), alpha = 0.2) + facet_grid(Tract~Hemisphere) + ylim(0, 1) +
  stat_summary(aes(group = 1), fun.data = groupStat, geom = 'smooth', alpha = 0.2) + theme_bw()

p2 <- ggplot(aes(x = Position, y = FA), data = trk_data_asym)
p2 <- p2 + geom_line(aes(group = ID), alpha = 0.2) + facet_grid(Tract~Hemisphere) + ylim(0, 1) +
  stat_summary(aes(group = 1), fun.data = groupStat, geom = 'smooth', alpha = 0.2) + theme_bw()

grid.arrange(p1, p2, ncol = 2)

trk_data_sym_FD$From <- rep('sym', nrow(trk_data_sym_FD))
trk_data_asym_FD$From <- rep('asym', nrow(trk_data_asym_FD))

trk_data_FD <- rbind(trk_data_sym_FD, trk_data_asym_FD)
trk_data_FD$From <- factor(trk_data_FD$From)

trk_CST <- filter(trk_data_FD, Tract == 'CST')

pTtest <- function(df) {
  t.test(filter(df, From == 'sym')$FD, filter(df, From == 'asym')$FD, paired = T)
}

tResult <- dlply(trk_data_FD, c('Tract'), pTtest)

#
#
# trk_data_sim <- dlply(trk_data, c('ID'), FDcalc_vec)
# trk_data_sim_mean <- vapply(trk_data_sim, mean, as.numeric(0))




