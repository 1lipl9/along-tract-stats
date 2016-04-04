exptDir = file.path('F:', 'ShaofengDuan', 'cerebral_infarction_statistics', 'after_del')
grpLabs = c('PAT', 'NOR')
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

source('funcToTest.R')
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
trk_data              = merge(trk_data, trk_props_long)

myPlot <- function(dt) {
  label = dt$ID[1]
  p <- ggplot(aes(x = Point, y = FA), data = dt)
  p <- p + geom_line(aes(color = Hemisphere, group = Hemisphere)) + 
    annotate("text", x = 20, y = 0.5, label = label)
  print(p)
}

pdf('test.pdf')

d_ply(trk_data, 'ID', myPlot)

dev.off()