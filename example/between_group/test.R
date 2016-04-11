library(reshape2)
library(dplyr)

exptDir <- file.path('F:', 'ShaofengDuan', 'cerebral_infarction_statistics', 'after_del_FA')

demog2 <- read.table(file.path(exptDir, 'Demographics2.txt'), 
                     sep = '\t', header = T)
demog2 <- melt(demog2, id = c('ID'))
names(demog2)[c(2, 3)] <- c('Hemisphere', 'State')
demog2$State <- factor(demog2$State)
demog2 <- arrange(demog2, ID)