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

trk_data_select <- filter(trk_data, Tract == 'CST')
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
  if(subset(models$anova, Term=="Point:Hemisphere")$p.value < 1){
    onpts  = df$Point[dsig==1]  + 0.5
    offpts = df$Point[dsig==-1] + 0.5
    # Check for any unclosed segments
    if(length(which(dsig != 0)) != 0 && dsig[which(dsig != 0)[1]] == -1) {
      onpts = c(1, onpts)
    }
    if(length(which(dsig != 0)) != 0 && dsig[rev(which(dsig != 0))[1]] == 1) {
      offpts = c(offpts, length(dsig))
    }
    
    df <- data.frame(on = (onpts-1)  * 100/(length(df$Point)-1),
               off = (offpts-1) * 100/(length(df$Point)-1))
    if(nrow(df) == 0) {
      df <- data.frame(on = 0, off = 0)
    }
    df
  } else df <- data.frame(on=0, off=0)
}

groupAna <- function(df) {
  data.frame(y = mean(df), ymin = mean(df) - sd(df), ymax = mean(df) + sd(df))
}

lin_interp = function(x, spacing=0.01) {
  approx(1:length(x), x, xout=seq(1,length(x), spacing))$y
}
###############################################################################
models = list()
models$anova = fit_trk_model1(trk_data_select, 'Hemisphere')
models$tTable = fit_trk_model2(trk_data_select, 'Hemisphere')
models$tTable = transform(models$tTable, Position = (as.numeric(Point)-1) * 
                                100/(max(as.numeric(Point))-1))
# If the F-test across the Point:Group terms in a panel is significant, 
#plot a bar at the bottom to indicate which pointwise t-tests are significant

break_list = get_breaks(models, thresh)

# sig_bars   = geom_segment(aes(x=on, y=0.2, xend=off, yend=0.2, group=NULL, size=NULL), 
#                           data=break_list, colour='black', arrow = arrow(length = unit(0.1,"cm")))
sig_rect <- annotate('rect', xmin = break_list$on, xmax = break_list$off, ymin = 0, ymax = 1, alpha = 0.2)

p1 <- ggplot(trk_data_select, aes(x = Position, y = FA)) + labs(y = 'FA')
p1 <- p1 + geom_line(aes(group = ID:Hemisphere, color = Hemisphere), alpha = 0.2) + 
  stat_summary(aes(group = Hemisphere, fill = Hemisphere, color = Hemisphere),
               fun.data = groupAna, geom = 'smooth', alpha = 0.3) + sig_rect + theme_bw() +
  theme(axis.title = element_text(size = 12), axis.text = element_text(size = 12))

colfunc <- colwise(lin_interp, c('Point','t.value', 'p.value', 
                                 'Position'))
models$tTable.interp <- colfunc(models$tTable)


sigFig = ggplot(data=models$tTable.interp, aes(x=Position, y=p.value, color=p.value < 0.05, 
                                                       group=1)) + geom_line() + 
  xlab('Position along tract (%)') + scale_color_manual('p.value < 0.05', values=c('red', 'green'))

# Gray out non-significant areas
grayout_p = annotate('rect', xmin=0, xmax=100, ymin=0.05, ymax=1, alpha=0.25)

# Make final plot
p_sig <- sigFig + grayout_p + scale_y_log10(limits=c(0.00001, 1), breaks=c(0.001, 0.01, 0.1, 1)) + theme_bw()

pval <- models$tTable$p.value
Filename2W <- paste0(format(Sys.time(), '%m_%d_%H_%M_%S'), '.csv')
write.table(-log10(pval), file = Filename2W, sep = ',', row.names = F)
# write.table(models$anova, file = 'rd_anova.csv', sep = ',')