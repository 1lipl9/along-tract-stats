exptDir = choose.dir(getwd(), 'select a health dir..')
thresh  = 0.01
nPerms  = 100

library(nlme)         # Mixed-effects models
library(ggplot2)      # Plotting tools
library(plyr)         # Data manipulation
library(RColorBrewer) # Color tables
library(dplyr)
library(reshape2)
library(gridExtra)
################################################################################
# Import and format data
# Read in demographics
# Identify the unormal side

# Read in whole-track properties (ex: streamlines) and merge with demographics
trk_props_long = read.table(file.path(exptDir, 'trk_props_long.txt'), header=T)

# Read in length-parameterized track data (ex: FA) and merge with demographics
trk_data              = read.table(file.path(exptDir, 'trk_data.txt'),  header=T)
trk_data$Point        = factor(trk_data$Point)
trk_data[trk_data==0] = NA
trk_data              = merge(trk_data, trk_props_long)
# Add a Position column for easier plotting
trk_data              = ddply(trk_data, c("Tract", "Hemisphere"),
                              transform, Position = 
                                (as.numeric(Point)-1) * 100/(max(as.numeric(Point))-1))

trk_data$ID <- factor(trk_data$ID, 
                      labels = c('Asymmetric Template', 'Symmetric Template'))

lin_interp = function(x, spacing=0.01) {
  approx(1:length(x), x, xout=seq(1,length(x), spacing))$y
}

p1 <- ggplot(trk_data, aes(x = Position, y = FA)) + labs(y = 'FA')
p1 <- p1 + geom_line(aes(color = Hemisphere), size = 1.5) + 
  theme_bw() +
  theme(axis.title = element_text(size = 12), axis.text = element_text(size = 12)) +
  facet_grid(Tract~ID) + theme(strip.text = element_text(size = 12))