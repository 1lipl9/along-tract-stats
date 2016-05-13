# This sctripts just used to contrast the correspond between
# registered tracts and real tracts.

exptDir = choose.dir();
grpLabs = c('nor', 'reg')
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
demog$Group = factor(demog$Group, levels=rev(levels(demog$Group)),
                     labels=grpLabs)

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


rCalc <- function(df) {
  tryCatch({new_df <- df %>% arrange(ID, Point)
  new_new_df <- cbind(L = select(filter(new_df, Group == 'nor'), FA),
                      R = select(filter(new_df, Group == 'reg'), FA))
  names(new_new_df) <- c('nor', 'reg')

  rValueMat = corr.test(new_new_df)
  rValue = rValueMat$r[1,2]
  data.frame(rValue = rValue, Tract = unique(df$Tract),
                      Hemisphere = unique(df$Hemisphere))},
  error = function(e) {
    f <- data.frame(rValue = as.numeric(), Tract = as.character(), Hemisphere = as.character())
    return(f)
  })
}

FDCalc <- function(df) {
  tryCatch({new_df <- df %>% arrange(ID,  Point)
  new_new_df <- cbind(L = select(filter(new_df, Group == 'nor'), FA),
                      R = select(filter(new_df, Group == 'reg'), FA))
  names(new_new_df) <- c('nor', 'reg')
  FDValue = transmute(new_new_df, FD = sum(abs(nor-reg))/nrow(new_new_df))[1, ]
  data.frame(FDValue = FDValue, Tract = unique(df$Tract),
             Hemisphere = unique(df$Hemisphere))},
  error = function(e) {
    f <- data.frame(FDValue = as.numeric(), Tract = as.character(), Hemisphere = as.character())
    return(f)
    })
}

rValue_df <- ddply(trk_data, c('Person', 'Tract', 'Hemisphere'), rCalc)
FDValue_df <- ddply(trk_data, c('Person', 'Tract', 'Hemisphere'), FDCalc)



