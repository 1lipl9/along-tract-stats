# This sctripts just used to contrast the correspond between
# registered tracts and real tracts.

exptDir = choose.dir();
thresh  = 0.05
nPerms  = 100

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

# source('funcToTest.R')
################################################################################
# Import and format data
# Read in demographics
demog       = read.table(file.path(exptDir, 'Demographics.txt'), header=T)
demog$Group = factor(demog$Group)

# Read in whole-track properties (ex: streamlines) and merge with demographics
trk_props_long = read.table(file.path(exptDir, 'trk_props_long.txt'), header=T)
trk_props_long = merge(trk_props_long, demog)

# Read in length-parameterized track data (ex: FA) and merge with demographics
trk_data              = read.table(file.path(exptDir, 'trk_data.txt'),
                                   header=T)

trk_data$Point        = factor(trk_data$Point)
trk_data[trk_data==0] = NA
trk_data              = merge(trk_data, trk_props_long)
# Add a Position column for easier plotting
trk_data              = ddply(trk_data, c("Tract", "Hemisphere"),
                        transform,
                        Position = (as.numeric(Point)-1) * 100/
                          (max(as.numeric(Point))-1))



# add within group contrast

trk_data_nor <- filter(trk_data, Group == 'nor') # trk data self tracked
trk_data_reg <- filter(trk_data, Group == 'reg') # trk data  registered edition

FDcalc <- function(df1, df2) {
  FDvalue <- sum(abs(df1-df2))/nrow(df1)
}

recur <- function(df) {
  if(ncol(df) < 3) {
    FDVal <- FDcalc(df[, 1], df[, 2])
    return(FDVal)
  }
  df_sim <- df[, -1]
  FDVal <- c(recur(df[, -1]), aaply(df_sim, 2, FDcalc, df[, 1]))
  return(FDVal)
}

FDcalc_vec <- function(df) {
  df_sim <- select(df, c(ID, Point, FA))
  df_sim_melt <- melt(df_sim, id = c('ID', 'Point'), measure.vars = c('FA'))
  df_sim_cast <- dcast(df_sim_melt, Point~ID)
  FDVal <- recur(df_sim_cast[, -1])
}

p1 <- ggplot(aes(x = Position, y = FA), data = trk_data_nor)
p1 <- p1 + geom_line(aes(group = ID)) + facet_grid(Tract~Hemisphere)

p2 <- ggplot(aes(x = Position, y = FA), data = trk_data_reg)
p2 <- p2 + geom_line(aes(group = ID)) + facet_grid(Tract~Hemisphere)

trk_data_nor_sim <- dlply(trk_data_nor, c('Tract', 'Hemisphere'), FDcalc_vec)
trk_data_reg_sim <- dlply(trk_data_reg, c('Tract', 'Hemisphere'), FDcalc_vec)

#----------------------------

# rCalc <- function(df) {
#   tryCatch({new_df <- df %>% arrange(ID, Point)
#   new_new_df <- cbind(L = select(filter(new_df, Group == 'nor'), FA),
#                       R = select(filter(new_df, Group == 'reg'), FA))
#   names(new_new_df) <- c('nor', 'reg')
#
#   rValueMat = corr.test(new_new_df)
#   rValue = rValueMat$r[1,2]
#   data.frame(rValue = rValue, Tract = unique(df$Tract),
#                       Hemisphere = unique(df$Hemisphere))},
#   error = function(e) {
#     f <- data.frame(rValue = as.numeric(), Tract = as.character(), Hemisphere = as.character())
#     return(f)
#   })
# }
#
# FDCalc <- function(df) {
#   tryCatch({new_df <- df %>% arrange(ID,  Point)
#   new_new_df <- cbind(L = select(filter(new_df, Group == 'nor'), FA),
#                       R = select(filter(new_df, Group == 'reg'), FA))
#   names(new_new_df) <- c('nor', 'reg')
#   FDValue = transmute(new_new_df, FD = sum(abs(nor-reg))/nrow(new_new_df))[1, ]
#   data.frame(FDValue = FDValue, Tract = unique(df$Tract),
#              Hemisphere = unique(df$Hemisphere))},
#   error = function(e) {
#     f <- data.frame(FDValue = as.numeric(), Tract = as.character(), Hemisphere = as.character())
#     return(f)
#     })
# }
#
# rValue_df <- ddply(trk_data, c('Person', 'Tract', 'Hemisphere'), rCalc)
# FDValue_df <- ddply(trk_data, c('Person', 'Tract', 'Hemisphere'), FDCalc)



