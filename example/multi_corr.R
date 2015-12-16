elibrary(dplyr)
library(psych)

exDir    = 'G:/Matlab/track_reg/CSTanalysis/sym/template/example/multi'
trk_info = read.table(file.path(exDir, 'tract_info.txt'), header=T, sep='\t')
grpLabs = c('SDCP', 'Control')

demog       = read.table(file.path(exDir, 'Demographics.txt'), header=T)
demog$Group = factor(demog$Group, levels=rev(levels(demog$Group)), labels=grpLabs)

readTrk <- function(subName, iTrk){
  trkName = sprintf('%s_%s', trk_info$Tract[iTrk], trk_info$Hemisphere[iTrk])
  path = file.path(exDir, sprintf('%s_%s.txt', subName, trkName))
  single_sub            = read.table(path, header=T)
  single_sub$Streamline = factor(single_sub$Streamline)
  single_sub$Point      = factor(single_sub$Point)
  return(single_sub)
}

groupSum <- function(df, ...) {
  meanVal <- group_by(df, ...) %>% 
    summarise(meanFA = mean(FA))
  return(meanVal)
}

corrData <- numeric(0)
for(subName in demog$ID) {
  sumVal <- data.frame(numeric(0), numeric(0))
  for(iTrk in 1:nrow(trk_info)){
    single_sub <- readTrk(subName, iTrk)
    tempdata <- as.data.frame(groupSum(single_sub, Point))
    sumVal[, iTrk] <- tempdata$meanFA
    names(sumVal)[iTrk] <- sprintf('%s_%s', trk_info$Tract[iTrk], 
                                   trk_info$Hemisphere[iTrk])
  }
  corrCoef <- cor.test(as.formula(sumVal))
  corrData <- c(corrData, corrCoef)
}

finalData <- data.frame(corrData = corrData, group = demog$Group)