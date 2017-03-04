
# it is used to analyze patient group.

exptDir = choose.dir(getwd(), 'select a patient dir..')
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
demog       = read.table(file.path(exptDir, 'Demographics.txt'), header=T)
demog$Group = factor(demog$Group)


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

trk_data_pat <- filter(trk_data, Tract == 'CST')
trk_data_pat$State <- rep('normal', nrow(trk_data_pat))
trk_data_pat[which(trk_data_pat$Hemisphere == 'L' & trk_data_pat$Group == 'LS'),]$State <- 'unormal'
trk_data_pat[which(trk_data_pat$Hemisphere == 'R' & trk_data_pat$Group == 'RS'),]$State <- 'unormal'
trk_data_pat$State <- factor(trk_data_pat$State)
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

get_breaks <- function(models, thresh=0.05){
  df <- models$tTable
  sig  = df$p.value < thresh
  dsig = c(diff(sig), 0)
  if(subset(models$anova, Term=="Point:State")$p.value < thresh){
    onpts  = df$Point[dsig==1]  + 0.5
    offpts = df$Point[dsig==-1] + 0.5
    
    # Check for any unclosed segments
    if(dsig[which(dsig != 0)[1]] == -1) {
      onpts = c(1, onpts)
    }
    if(dsig[rev(which(dsig != 0))[1]] == 1) {
      offpts = c(offpts, length(dsig))
    }
    
    data.frame(on = (onpts-1)  * 100/(length(df$Point)-1),
               off = (offpts-1) * 100/(length(df$Point)-1))
  } else data.frame(on=0, off=0)
}

groupAna <- function(df) {
  data.frame(y = mean(df), ymin = mean(df) - sd(df), ymax = mean(df) + sd(df))
}

lin_interp = function(x, spacing=0.01) {
  approx(1:length(x), x, xout=seq(1,length(x), spacing))$y
}
###############################################################################
models_pat = list()
models_pat$anova = fit_trk_model1(trk_data_pat, 'State')
models_pat$tTable = fit_trk_model2(trk_data_pat, 'State')
models_pat$tTable = transform(models_pat$tTable, Position = (as.numeric(Point)-1) * 
                                100/(max(as.numeric(Point))-1))
# If the F-test across the Point:Group terms in a panel is significant, 
#plot a bar at the bottom to indicate which pointwise t-tests are significant

break_list = get_breaks(models_pat, thresh)

# sig_bars   = geom_segment(aes(x=on, y=0.2, xend=off, yend=0.2, group=NULL, size=NULL), 
#                           data=break_list, colour='black', arrow = arrow(length = unit(0.1,"cm")))
sig_rect <- annotate('rect', xmin = break_list$on, xmax = break_list$off, ymin = 0, ymax = 1, alpha = 0.2)

p_pat <- ggplot(trk_data_pat, aes(x = Position, y = FA))
p_pat <- p_pat + geom_line(aes(group = ID:State, color = State), alpha = 0.2) + 
  stat_summary(aes(group = State, fill = State, color = State),
               fun.data = groupAna, geom = 'smooth', alpha = 0.3) + sig_rect + theme_bw() +
  theme(axis.title = element_text(size = 12), axis.text = element_text(size = 12))

colfunc <- colwise(lin_interp, c('Point','t.value', 'p.value', 
                                 'Position'))
models_pat$tTable.interp <- colfunc(models_pat$tTable)


sigFig_pat = ggplot(data=models_pat$tTable.interp, aes(x=Position, y=p.value, color=p.value < 0.05, 
                                                       group=1)) + geom_line() + 
  xlab('Position along tract (%)') + scale_color_manual('p.value < 0.05', values=c('red', 'green'))

# Gray out non-significant areas
grayout_p = annotate('rect', xmin=0, xmax=100, ymin=0.05, ymax=1, alpha=0.25)

# Make final plot
p_sig_pat <- sigFig_pat + grayout_p + scale_y_log10(limits=c(0.00001, 1), breaks=c(0.001, 0.01, 0.1, 1)) + theme_bw()

pval <- models_pat$tTable$p.value
Filename2W <- paste0(format(Sys.time(), '%m_%d_%H_%M_%S'), '.csv')
write.table(pval, file = Filename2W, sep = ',', row.names = F)

