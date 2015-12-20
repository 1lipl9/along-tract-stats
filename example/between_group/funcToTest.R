library(nlme)         # Mixed-effects models
library(ggplot2)      # Plotting tools
library(dplyr)         # Data manipulation
library(RColorBrewer) # Color tables
library(psych)

fit_trk_model1 <- function(df){
  lme.trk = lme(FA ~ Point*Group, data=df, random = ~ 1 | ID, na.action=na.omit)
  data.frame(Term = rownames(anova(lme.trk)), anova(lme.trk))
}

fit_trk_model2 <- function(df){
  lme.trk = tryCatch(lme(FA ~ Point/Group - 1, data=df, random = ~ 1 | ID, na.action=na.omit), error = function(e) data.frame())
  if(length(lme.trk)!=0){
    term.RE = paste('Point[0-9]+:', 'Group', '.+', sep='')
    term.rows = grep(term.RE, row.names(summary(lme.trk)$tTable))
    data.frame(Point = as.numeric(levels(factor(df$Point))),
               summary(lme.trk)$tTable[term.rows,])
  } else data.frame()
}

getP <- function(testT, maxT){
  # If you do 1000 permutations and the result from the real dataset is the
  # most extreme, then the empirical p-value is 1/1001
  (1+length(maxT[abs(testT) < maxT]))/(length(maxT)+1)
}

corTest <- function(df) {
  if(~is.matrix(df)) {
    df <- as.matrix(df)
  }
  
  corr.test(df, use = 'complete')
}

plotFunc <- function(trk_data) {
  # the data is casted to do the corr analysis
  trk_data_melt <- select(trk_data, one_of(c('Point', 'ID', 'FA')))
  colnames(trk_data_melt)[3] <- 'Value'
  trk_data_cast <- dcast(trk_data_melt, Point~ID)
  
  varaa <- as.matrix(trk_data_cast[, -1])
  varbb <- corr.test(varaa)
  print(varbb)
  
  ########
  # # Plot FA vs. position, conditioned on hemisphere, tract, and group
  p3 <- ggplot(data = trk_data, aes(x = Position, y = FA))
  p3 <- p3 + geom_line(aes(group = ID, color = Group), alpha = 0.3) + xlab('Position along tract (%)') 
  p3 <- p3 + geom_smooth(aes(group = Group, color = Group))
  
  # p3 <- p3 + geom_area(aes(group = 1, xmin = 60, xmax = 70, ymin = 0, ymax = 1), fill = 'red') + theme_rect(alpha = 0.2)
  dev.new(width = 7, height = 4)
  print(p3)
  
  dev.new()
  corrgram(trk_data_cast[,-1], lower.panel = panel.pie, 
           upper.panel = panel.pts,
           text.panel = panel.txt, 
           main = 'The CST_R FA profiles\' correlation')
}