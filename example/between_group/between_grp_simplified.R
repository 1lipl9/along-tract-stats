exptDir = file.path('F:', 'ShaofengDuan', 'cerebral_infarction_statistics', 'after_del_FA')
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
trk_data[trk_data==0] = NA
trk_data              = merge(trk_data, trk_props_long)
# Add a Position column for easier plotting
trk_data              = ddply(trk_data, c("Tract", "Hemisphere"),
                        transform, 
                        Position = (as.numeric(Point)-1) * 100/
                          (max(as.numeric(Point))-1))

#Calculate the sd value for each group and hemisphere.
sdVal <- trk_data %>% group_by(Group, Hemisphere, Point) %>% do(sdVal = sd(.$FA))
sdVal <- as.data.frame(sdVal)
sdVal$sdVal <- as.numeric(sdVal$sdVal)

pValCalc <- function(df) {
  pairT <- t.test(sdVal ~ Group, df, paired = T)
  pairT$p.value
}
pVal <- group_by(sdVal, Hemisphere) %>% do(pVal = pValCalc(.))


groupAna1 <- function(df) {
  data.frame(y = sd(df))
}
groupAna2 <- function(df) {
  data.frame(y = mean(df), ymin = mean(df) - sd(df), ymax = mean(df) + sd(df))
}
rValue_df <- ddply(trk_data, c('ID'), corTest)
FDValue_df <- ddply(trk_data, c('ID'), FDCalc)
pairedTValue_df <- ddply(trk_data, c('ID'), pairedTest)

rValueP <- pvalue(oneway_test(rValue~Group, data = rValue_df))/2
FDValueP <- pvalue(oneway_test(FDValue~Group, data = FDValue_df))/2

rValueFig <- ggplot(rValue_df, aes(x = Group, y = rValue))
rValueFig <- rValueFig + geom_point() + 
  stat_summary(aes(group = Group), fun.data = groupAna2, geom = 'crossbar') + 
  ylim(0, 1) + labs(y = "r")

FDValueFig <- ggplot(FDValue_df, aes(x = Group, y = FDValue))
FDValueFig <- FDValueFig + geom_point() + 
  stat_summary(aes(group = Group), fun.data = groupAna2, geom = 'crossbar') + 
  ylab('FD')
# dev.new()
# grid.arrange(rValueFig, FDValueFig, nrow = 1)

p <- ggplot(trk_data, aes(x = Position, y = FA))
p <- p + facet_grid(~Group) + geom_line(aes(group = ID:Hemisphere, 
                                            color = Hemisphere), alpha = 0.2) + 
  stat_summary(aes(group = Hemisphere, fill = Hemisphere, color = Hemisphere),
               fun.data = groupAna2, geom = 'smooth', alpha = 0.3) + 
  stat_summary(aes(group = Hemisphere, color = Hemisphere), fun.data = groupAna1, geom = 'line')
# 画方差值  

extractPval <- function(df) {
  pvalue(oneway_test(FA~Hemisphere, data = df))/2
}
modlist <- trk_data %>% group_by(Point, Group) %>% 
  do(mod = extractPval(.))
tt <- vapply(modlist$mod, function(x) {aa <- x[[1]][1]; aa}, numeric(1))
modlist_df <- as.data.frame(modlist)
modlist_df$mod <- tt
multPval <- filter(modlist_df, Group == "SDCP")
adjustPval <- p.adjust(multPval$mod)