exptDir = file.path('F:', 'ShaofengDuan', 'cerebral_infarction_statistics', 'after_del_FA')
grpLabs = c('PAT', 'NOR')
thresh  = 0.05
nPerms  = 100

library(nlme)         # Mixed-effects models
library(ggplot2)      # Plotting tools
library(plyr)         # Data manipulation
library(RColorBrewer) # Color tables

################################################################################
# Import and format data
# Read in demographics
demog1       = read.table(file.path(exptDir, 'Demographics.txt'), header=T)
demog1$Group = factor(demog1$Group, levels=rev(levels(demog1$Group)), labels=grpLabs)
#################################################################################
# Identify the unormal side
demog2 <- read.table(file.path(exptDir, 'Demographics2.txt'),                     sep = '\t', header = T)
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

trk_data_PAT <- filter(trk_data, Group == 'PAT')

groupAna1 <- function(df) {
  data.frame(y = sd(df))
}
groupAna2 <- function(df) {
  data.frame(y = mean(df), ymin = min(df), ymax = max(df))
}
p <- ggplot(trk_data_PAT, aes(x = Position, y = FA))
p <- p  + geom_line(aes(group = ID:State, color = State), alpha = 0.2) + 
  stat_summary(aes(group = State, fill = State, color = State),
               fun.data = groupAna2, geom = 'smooth', alpha = 0.2) + 
  stat_summary(aes(group = State, color = State), fun.data = groupAna1, 
               geom = 'line')

# statistics

fit_trk_model1 <- function(df){
  lme.trk = tryCatch(lme(FA ~ Point*State, data=df, random = ~ 1 | ID, 
                         na.action=na.omit),
                     error = function(e) data.frame())
  if(length(lme.trk)!=0){
    data.frame(Term = rownames(anova(lme.trk)), anova(lme.trk))
  } else data.frame()
}
fit_trk_model2 <- function(df){
  lme.trk = tryCatch(lme(FA ~ Point/State - 1, 
                         data=df, random = ~ 1 | ID, na.action=na.omit), 
                     error = function(e) data.frame())
  if(length(lme.trk)!=0){
    term.RE = paste('Point[0-9]+:', 'State', '.+', sep='')
    term.rows = grep(term.RE, row.names(summary(lme.trk)$tTable))
    data.frame(Point = as.numeric(levels(factor(df$Point))),
               summary(lme.trk)$tTable[term.rows,])
  } else data.frame()
}

models = list()
models$anova = ddply(trk_data, c('Group'), fit_trk_model1)
models$tTable = ddply(trk_data, c("Group"), fit_trk_model2)


