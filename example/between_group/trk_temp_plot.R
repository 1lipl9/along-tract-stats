#This script is used to plot the template FA profile
exptDir = choose.dir();

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

# Read in whole-track properties (ex: streamlines) and merge with demographics
trk_props_long = read.table(file.path(exptDir, 'trk_props_long.txt'), header=T)

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





p1 <- ggplot(aes(x = Position, y = FA), data = trk_data)
p1 <- p1 + geom_line(aes(group = ID)) + facet_grid(Tract~Hemisphere) + ylim(0, 1)



