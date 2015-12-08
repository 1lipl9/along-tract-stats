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