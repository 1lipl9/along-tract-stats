# This scripts used to calculated the Asymmetry index discrepancy between the
#health and patient

exptDir1 = choose.dir(getwd(), caption = "Select output of patients");
exptDir2 = choose.dir(exptDir1, caption = "Select output of controls");

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
# Read in whole-track properties (ex: streamlines) and merge with demographics

# function to read data --------------------------------------------------------
readData <- function(exptDir) {
  
  trk_props_long = read.table(file.path(exptDir, 'trk_props_long.txt'), header=T)
  if (file.exists(file.path(exptDir, 'Demographics.txt'))) {
    demog       = read.table(file.path(exptDir, 'Demographics.txt'), header=T)
    demog$Group = factor(demog$Group)
    trk_props_long = merge(trk_props_long, demog)
  }
  
  # Read in length-parameterized track data (ex: FA) and merge with demographics
  trk_data              = read.table(file.path(exptDir, 'trk_data.txt'),
                                     header=T)
  
  trk_data$Point        = factor(trk_data$Point)
  # trk_data[trk_data==0] = NA
  trk_data              = merge(trk_data, trk_props_long)
  # Add a Position column for easier plotting
  trk_data              = ddply(trk_data, c("Tract", "Hemisphere"),
                                transform,
                                Position = (as.numeric(Point)-1) * 100/
                                  (max(as.numeric(Point))-1))
  if (file.exists(file.path(exptDir, 'Demographics.txt'))) {
    trk_data$State <- rep('normal', nrow(trk_data))
    trk_data[which(trk_data$Hemisphere == 'L' & trk_data$Group == 'LS'),]$State <- 'unormal'
    trk_data[which(trk_data$Hemisphere == 'R' & trk_data$Group == 'RS'),]$State <- 'unormal'
    trk_data$State <- factor(trk_data$State)
  }
  invisible(trk_data)
}

# add within group contrast ---------------------------------------------------

# calculate asymmetry index (R - L)/(R + L)
AIcalc <- function(df1, df2) {
  AIvalue <- (df2$FA-df1$FA)/(df1$FA + df2$FA);
}

# calculate the asymmetry index.
df_AI_calc <- function(df) {
  if(ncol(df) > 8) {
    df_L <- filter(df, State == "unormal")
    df_R <- filter(df, State == 'normal')
  } else {
    df_L <- filter(df, Hemisphere == "L")
    df_R <- filter(df, Hemisphere == "R")
  }
  
  data.frame(ID = unique(df$ID), Tract = unique(df$Tract), Point = df_L$Point, Position = df_L$Position, AI = AIcalc(df_L, df_R))
}

# mean value and std value -----------------------------------------------------
groupStat <- function(df) {
  data.frame(y = mean(df), ymin = mean(df) - sd(df), ymax = mean(df) + sd(df))
}


################################################################################
# Fit LME models
# Overall ANOVA for Group and Point:Group effects
fit_trk_model1 <- function(df, groupfac){
  xnam <- c('Point', groupfac)
  fmla <- as.formula(paste("AI ~", paste(xnam, collapse = '*')))
  lme.trk = lme(fmla, data=df, random = ~ 1 | ID, na.action=na.omit)
  data.frame(Term = rownames(anova(lme.trk)), anova(lme.trk))
}
# Fit a cell-means version to get effect sizes relative to controls
fit_trk_model2 <- function(df, groupfac){
  xnam <- c('Point', groupfac)
  fmla <- as.formula(paste("AI ~", paste(xnam, collapse = '/'), ' - 1'))
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
  if(subset(models$anova, Term=="Point:From")$p.value < thresh){
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

# read data ------------------------------------------------------------------
trk_data_pat  <- readData(exptDir1)
trk_data_crl <- readData(exptDir2)

trk_data_pat_AI  <- ddply(trk_data_pat, c('ID', 'Tract'), df_AI_calc)
trk_data_crl_AI <- ddply(trk_data_crl, c('ID', 'Tract'), df_AI_calc)


trk_data_pat_AI$From <- rep('pat', nrow(trk_data_pat_AI))
trk_data_crl_AI$From <- rep('crl', nrow(trk_data_crl_AI))

trk_data_pat_AI_CST <- filter(trk_data_pat_AI, Tract == 'CST')
trk_data_crl_AI_CST <- filter(trk_data_crl_AI, Tract == 'CST')

trk_data_AI <- rbind(trk_data_pat_AI_CST, trk_data_crl_AI_CST)
trk_data_AI$From <- factor(trk_data_AI$From)
models_pat = list()
models_pat$anova = fit_trk_model1(trk_data_AI, 'From')
models_pat$tTable = fit_trk_model2(trk_data_AI, 'From')
models_pat$tTable = transform(models_pat$tTable, Position = (as.numeric(Point)-1) * 
                                100/(max(as.numeric(Point))-1))
# If the F-test across the Point:Group terms in a panel is significant, 
#plot a bar at the bottom to indicate which pointwise t-tests are significant

break_list = get_breaks(models_pat, 0.05)

# sig_bars   = geom_segment(aes(x=on, y=0.2, xend=off, yend=0.2, group=NULL, size=NULL), 
#                           data=break_list, colour='black', arrow = arrow(length = unit(0.1,"cm")))
sig_rect <- annotate('rect', xmin = break_list$on, xmax = break_list$off, ymin = -0.6, ymax = 0.6, alpha = 0.2)

p_pat <- ggplot(trk_data_AI, aes(x = Position, y = AI))
p_pat <- p_pat + geom_line(aes(group = ID:From, color = From), alpha = 0.2) + 
  stat_summary(aes(group = From, fill = From, color = From),
               fun.data = groupAna, geom = 'smooth', alpha = 0.3) + sig_rect + theme_bw() + ylim(-0.6, 0.6) +
  theme(axis.title = element_text(size = 12), axis.text = element_text(size = 12)) + 
  ylab('Asymmetry Index')

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
#
#
# trk_data_sim <- dlply(trk_data, c('ID'), FDcalc_vec)
# trk_data_sim_mean <- vapply(trk_data_sim, mean, as.numeric(0))




