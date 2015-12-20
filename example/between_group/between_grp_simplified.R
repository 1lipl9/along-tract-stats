exptDir = 'G:/Matlab/track_reg/CSTanalysis/sym/template/example/multi'
grpLabs = c('SDCP', 'Control')
thresh  = 0.05
nPerms  = 100

library(nlme)         # Mixed-effects models
library(ggplot2)      # Plotting tools
library(dplyr)         # Data manipulation
library(plyr)
library(RColorBrewer) # Color tables
library(reshape2)
library(corrgram)
library(psych)

source('funcToTest.R')
################################################################################
# Import and format data
# Read in demographics
demog       = read.table(file.path(exptDir, 'Demographics.txt'), header=T)
demog$Group = factor(demog$Group, levels=rev(levels(demog$Group)), labels=grpLabs)

# Read in whole-track properties (ex: streamlines) and merge with demographics
trk_props_long = read.table(file.path(exptDir, 'trk_props_long.txt'), header=T)
trk_props_long = merge(trk_props_long, demog)

# Read in length-parameterized track data (ex: FA) and merge with demographics
trk_data              = read.table(file.path(exptDir, 'trk_data.txt'),  header=T)
trk_data$Point        = factor(trk_data$Point)
trk_data[trk_data==0] = NA
trk_data              = merge(trk_data, trk_props_long)
# Add a Position column for easier plotting
trk_data              = ddply(trk_data, c("Tract", "Hemisphere"),
                        transform, Position = (as.numeric(Point)-1) * 100/(max(as.numeric(Point))-1))

################################################################################
# Fit LME models
# Overall ANOVA for Group and Point:Group effects
models = list()
models$anova = ddply(trk_data, c("Tract", "Hemisphere"), fit_trk_model1)

# Fit a cell-means version to get effect sizes relative to controls

models$tTable = ddply(trk_data, c("Tract", "Hemisphere"), fit_trk_model2)

ddply(trk_data, c("Tract", "Hemisphere"), plotFunc)


# p3        = qplot(Position, FA, group=ID, colour=Group, size=Streamlines, 
#                   alpha=I(0.3), data=trk_data, facets = Tract~Hemisphere, 
#                   geom='line', xlab='Position along tract (%)') + scale_size(range=c(0.25,3))
# 
# # Set colors
# brew_cols = scale_colour_manual(values=rev(brewer.pal(2, 'Set1')[1:2]))
# 
# # Add group means
# means_smooth = stat_smooth(aes(ymax=..y..+1.96*..se.., ymin=..y..-1.96*..se.., group=Group), alpha=0.8, span=0.5)
# means        = stat_summary(fun.y=mean, geom='line', size=0.6, aes(group=Group))
# 
# # Add an asterisk if there is a significant main group effect
# anova_grp  = subset(models$anova, Term=="Group")
# Caption    = rep('', nrow(anova_grp))
# Caption[anova_grp$p.value<thresh] = '*'
# anova_grp  = data.frame(anova_grp, Caption)
# grp_effect = geom_text(aes(x=0, y=0.2, label=Caption, group=NULL, size=NULL), data=anova_grp, colour='black')
# 
# # If the F-test across the Point:Group terms in a panel is significant, plot a bar at the bottom to indicate which pointwise t-tests are significant
# get_breaks <- function(df, thresh=0.05){
#     sig  = df$p.value < thresh
#     dsig = c(diff(sig), 0)
#     if(subset(models$anova, Term=="Point:Group" & Tract==df$Tract[1] & Hemisphere==df$Hemisphere[1])$p.value < thresh){
#         onpts  = df$Point[dsig==1]  + 0.5
#         offpts = df$Point[dsig==-1] + 0.5
#         
#         # Check for any unclosed segments
#         if(dsig[which(dsig != 0)[1]] == -1) {
#             onpts = c(1, onpts)
#         }
#         if(dsig[rev(which(dsig != 0))[1]] == 1) {
#             offpts = c(offpts, length(dsig))
#         }
#         
#         data.frame(on = (onpts-1)  * 100/(length(df$Point)-1),
#                   off = (offpts-1) * 100/(length(df$Point)-1))
#     } else data.frame(on=0, off=0)
# }
# break_list = ddply(models$tTable, c("Tract", "Hemisphere"), get_breaks, thresh=thresh)
# sig_bars   = geom_segment(aes(x=on, y=0.2, xend=off, yend=0.2, group=NULL, size=NULL), data=break_list, colour='black')
# 
# # Make final plot
# dev.new(width=7, height=5)
# p3 + brew_cols + means_smooth + grp_effect + sig_bars

################################################################################
# Output statistical results for import into MATLAB and overlay onto mean tract # geometry
# write.table(models$tTable, file=file.path(exptDir, 'effects_table.txt'), quote=F, row.names=F)