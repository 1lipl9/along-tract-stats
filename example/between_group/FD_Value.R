library(tidyr)
library(plyr)
library(dplyr)
library(atlasBasedFiberAnalysis)

filename <- choose.files(getwd(), 'choose the file containing the FA value.')
FADt <- read.table(filename, sep = '\t')

df <- gather(FADt, 'Point', 'FA', 2:ncol(FADt))

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

df_new <- select(ddply(df, c('V1'), addCol), c(ID, Tract, Hemisphere, Point, FA))

calcFD <- function(df) {
  df_L <- filter(df, Hemisphere == 'L')
  df_R <- filter(df, Hemisphere == 'R')
  FDcalc(df_L, df_R)
}

FDVal <- daply(df_new, c('ID'), calcFD)

# used to plot boxplot figure, you should source between_sim_sim first.
stopifnot(exists('trk_CST'))
trk_subj_FD <- data_frame(FD = FDVal, From = rep('subj', length(FDVal)))
trk_atlas_FD <- select(trk_CST, c(FD, From))

trk_FD <- rbind(trk_subj_FD, trk_atlas_FD)
trk_FD$From <- factor(trk_FD$From, levels = c('asym', 'sym', 'subj'))

p_boxplot <- ggplot(aes(x = From, y = FD), data = trk_FD)
p_boxplot <- p_boxplot + geom_boxplot() +
       xlab('') + ylab('Functional Difference') + theme_bw() +
       theme(axis.text = element_text(size = 18),
              axis.title.y = element_text(size = 18)) + ylim(0, 0.15)
