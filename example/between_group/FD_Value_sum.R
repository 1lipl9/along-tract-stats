library(tidyr)
library(plyr)
library(dplyr)
library(coin)
library(atlasBasedFiberAnalysis)

#
addCol <- function(df) {
  subj <- as.character(df$V1[1])
  eleList <- strsplit(subj, '_')
  ID <- eleList[[1]][3]
  Hemisphere <- eleList[[1]][2]
  Tract <- eleList[[1]][1]
  df$Point <- 1:nrow(df)
  df$ID <- rep(ID, nrow(df))
  df$Tract <- rep(Tract, nrow(df))
  df$Hemisphere <- rep(Hemisphere, nrow(df))
  df
}
#
calcFD <- function(df) {
  df_L <- filter(df, Hemisphere == 'L')
  df_R <- filter(df, Hemisphere == 'R')
  FDcalc(df_L, df_R)
}
trk_FD_for_each_trk <- function(filename, trk_trk) {
  FADt <- read.table(filename, sep = '\t')
  df <- gather(FADt, 'Point', 'FA', 2:ncol(FADt))
  df_new <- select(ddply(df, c('V1'), addCol), c(ID, Tract, Hemisphere, Point, FA))
  FDVal <- daply(df_new, c('ID'), calcFD)
  
  # used to plot boxplot figure, you should source between_sim_sim first.
  # stopifnot(exists('trk_CING'))
  trk_subj_FD <- data_frame(FD = FDVal, From = rep('subj', length(FDVal)))
  trk_atlas_FD <- select(trk_trk, c(FD, From))
  
  trk_FD <- rbind(trk_subj_FD, trk_atlas_FD)
  trk_FD$From <- factor(trk_FD$From, levels = c('asym', 'sym', 'subj'))
  trk_FD
}
filenames <- choose.files(getwd(), 'choose the file containing the FA value.')

trk_FD_CING <- trk_FD_for_each_trk(filenames[1], trk_CING)
trk_FD_CING$Group <- rep('CING', nrow(trk_FD_CING))

trk_FD_CST <- trk_FD_for_each_trk(filenames[2], trk_CST)
trk_FD_CST$Group <- rep('CST', nrow(trk_FD_CST))

trk_FD_UNC <- trk_FD_for_each_trk(filenames[3], trk_UNC)
trk_FD_UNC$Group <- rep('UNC', nrow(trk_FD_UNC))

trk_FD_sum <- rbind(trk_FD_CING, trk_FD_CST, trk_FD_UNC)



p_boxplot <- ggplot(aes(x = From, y = FD), data = trk_FD_sum)
p_boxplot <- p_boxplot + geom_boxplot() +
  xlab('') + ylab('Functional Difference') + theme_bw() +
  theme(axis.text = element_text(size = 12),
        axis.title.y = element_text(size = 12)) + ylim(0, 0.2) + 
  facet_grid(.~Group)

FD_pval <- function(df) {
  df1 <- filter(df, From == 'subj' | From == 'asym')
  df2 <- filter(df, From == 'subj' | From == 'sym')
  pval1 <- pvalue(oneway_test(FD~From, df1))
  pval2 <- pvalue(oneway_test(FD~From, df2))
  pval_t <- data.frame(pval = c(pval1, pval2),group = c('asym', 'sym'))
}

fdpval <- rbind(FD_pval(trk_FD_CING), FD_pval(trk_FD_CST), 
               FD_pval(trk_FD_UNC))
fdpval$From = rep(c('CING', 'CST', 'UNC'), c(2, 2, 2))