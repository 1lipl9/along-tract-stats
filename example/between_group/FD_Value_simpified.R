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

p <- ggplot(aes(x = Point, y = FA), data = df_new)
p <- p + geom_line(aes(group = ID), colour = 'blue') + facet_grid(.~Hemisphere) + ylim(0, 1)