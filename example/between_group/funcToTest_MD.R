library(nlme)         # Mixed-effects models
library(ggplot2)      # Plotting tools
library(dplyr)         # Data manipulation
library(RColorBrewer) # Color tables
library(psych)

aov_trk_model <- function(df){
  fitValue <- aov(MD ~ Hemispere*Group + Error(ID), df)
  ### Herein need some other codes.
}

getP <- function(testT, maxT){
  # If you do 1000 permutations and the result from the real dataset is the
  # most extreme, then the empirical p-value is 1/1001
  (1+length(maxT[abs(testT) < maxT]))/(length(maxT)+1)
}

corTest <- function(df) {
  # browser()
  new_df <- df %>% arrange(Hemisphere, Point)
  new_new_df <- cbind(L = select(filter(new_df, Hemisphere == 'L'), MD),
                      R = select(filter(new_df, Hemisphere == 'R'), MD))
  names(new_new_df) <- c('L', 'R')
  rValueMat = corr.test(new_new_df)
  rValue = rValueMat$r[1,2]
  data.frame(rValue = rValue, Group = unique(df$Group))
}

pairedTest <- function(df) {
  new_df <- df %>% arrange(Hemisphere, Point)
  new_new_df <- select(new_df, Hemisphere, MD)
  pairedT <- t.test(MD~Hemisphere, data = new_new_df, paired = T)
  pairedPValue <- pairedT$p.value
  pairedTValue <- pairedT$statistic
  data.frame(pairedTValue = pairedTValue, pairedPValue = pairedPValue, 
             Group = unique(df$Group))
}
FDCalc <- function(df) {
  new_df <- df %>% arrange(Hemisphere, Point)
  new_new_df <- cbind(L = select(filter(new_df, Hemisphere == 'L'), MD),
                      R = select(filter(new_df, Hemisphere == 'R'), MD))
  names(new_new_df) <- c('L', 'R')
  FDValue = transmute(new_new_df, FD = sum(abs(L-R))/nrow(new_new_df))[1, ]
  data.frame(FDValue = FDValue, Group = unique(df$Group))
}
plotFunc <- function(trk_data) {
  # the data is casted to do the corr analysis
  trk_data_melt <- select(trk_data, one_of(c('Point', 'ID', 'MD')))
  colnames(trk_data_melt)[3] <- 'Value'
  trk_data_cast <- dcast(trk_data_melt, Point~ID)
  
  varaa <- as.matrix(trk_data_cast[, -1])
  varbb <- corr.test(varaa)
  print(varbb)
  
  ########
  # # Plot MD vs. position, conditioned on hemisphere, tract, and group
  p3 <- ggplot(data = trk_data, aes(x = Position, y = MD))
  p3 <- p3 + geom_line(aes(group = ID, color = Group), alpha = 0.3) + xlab('Position along tract (%)') 
  p3 <- p3 + geom_smooth(aes(group = Group, color = Group))
  
  # p3 <- p3 + geom_area(aes(group = 1, xmin = 60, xmax = 70, ymin = 0, ymax = 1), fill = 'red') + theme_rect(alpha = 0.2)
  dev.new(width = 7, height = 4)
  print(p3)
  
  dev.new()
  corrgram(trk_data_cast[,-1], lower.panel = panel.pie, 
           upper.panel = panel.pts,
           text.panel = panel.txt, 
           main = 'The CST_R MD profiles\' correlation')
}