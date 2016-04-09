exptDir = file.path('F:', 'ShaofengDuan', 'cerebral_infarction_statistics', 'after_del_FA')
grpLabs = c('PAT', 'NOR')
thresh  = 0.05
nPerms  = 100

library(nlme)         # Mixed-effects models
library(ggplot2)      # Plotting tools
library(plyr)         # Data manipulation
library(RColorBrewer) # Color tables
library(dplyr)
library(reshape2)
################################################################################
# Import and format data
# Read in demographics
# Identify the unormal side
demog1       = read.table(file.path(exptDir, 'Demographics.txt'), header=T)
demog1$Group = factor(demog1$Group, levels=rev(levels(demog1$Group)), labels=grpLabs)
demog2 <- read.table(file.path(exptDir, 'Demographics2.txt'), 
                     sep = '\t', header = T)
demog2 <- melt(demog2, id = c('ID'))
names(demog2)[c(2, 3)] <- c('Hemisphere', 'State')
demog2$State <- factor(demog2$State)
demog2 <- arrange(demog2, ID)

demog <- merge(demog1, demog2)

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
                              transform, Position = 
                                (as.numeric(Point)-1) * 100/(max(as.numeric(Point))-1))

trk_data_nor <- filter(trk_data, Group == 'NOR')
trk_data_pat <- filter(trk_data, Group == 'PAT')
################################################################################
# Fit LME models
# Overall ANOVA for Group and Point:Group effects
fit_trk_model1 <- function(df, groupfac){
  xnam <- c('Point', groupfac)
  fmla <- as.formula(paste("FA ~", paste(xnam, collapse = '*')))
  lme.trk = lme(fmla, data=df, random = ~ 1 | ID, na.action=na.omit)
  data.frame(Term = rownames(anova(lme.trk)), anova(lme.trk))
}
# Fit a cell-means version to get effect sizes relative to controls
fit_trk_model2 <- function(df, groupfac){
  xnam <- c('Point', groupfac)
  fmla <- as.formula(paste("FA ~", paste(xnam, collapse = '/'), ' - 1'))
  lme.trk = tryCatch(lme(fmla, 
                         data=df, random = ~ 1 | ID, na.action=na.omit), 
                     error = function(e) data.frame())
  if(length(lme.trk)!=0){
    term.RE = paste('Point[0-9]+:', groupfac, '.+', sep='')
    term.rows = grep(term.RE, row.names(summary(lme.trk)$tTable))
    data.frame(Point = as.numeric(levels(factor(df$Point))),
               summary(lme.trk)$tTable[term.rows,])
  } else data.frame()
}
models_nor = list()
models_nor$anova = fit_trk_model1(trk_data_nor, 'Hemisphere')
models_nor$tTable = fit_trk_model2(trk_data_nor, 'Hemisphere')

# fit_trk_model3 <- function(df){
#   lme.trk = lme(FA ~ Point*State, data=df, random = ~ 1 | ID, na.action=na.omit)
#   data.frame(Term = rownames(anova(lme.trk)), anova(lme.trk))
# }
# # Fit a cell-means version to get effect sizes relative to controls
# fit_trk_model4 <- function(df){
#   lme.trk = tryCatch(lme(FA ~ Point/State - 1, 
#                          data=df, random = ~ 1 | ID, na.action=na.omit), 
#                      error = function(e) data.frame())
#   if(length(lme.trk)!=0){
#     term.RE = paste('Point[0-9]+:', 'State', '.+', sep='')
#     term.rows = grep(term.RE, row.names(summary(lme.trk)$tTable))
#     data.frame(Point = as.numeric(levels(factor(df$Point))),
#                summary(lme.trk)$tTable[term.rows,])
#   } else data.frame()
# }

models_pat = list()
models_pat$anova = fit_trk_model1(trk_data_pat, 'State')
models_pat$tTable = fit_trk_model2(trk_data_pat, 'State')
