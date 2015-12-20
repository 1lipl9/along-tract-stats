library('plyr')
library('dplyr')
library('reshape2')

exptDir = 'G:/Matlab/track_reg/CSTanalysis/AAAmatfiles/segment'
subname = 'chengyuqi'

expFile <- file.path(exptDir, subname, 'resample/FA.txt')
regFile <- file.path(exptDir, subname, 'resample', 
                     paste(subname, '.txt', sep = ''))

df_explore <- read.table(expFile, sep = '\t')
df_explore <- melt(df_explore, id = 'V1')
names(df_explore)[3] <- 'FA'
df_explore <- arrange(df_explore, V1)

df_reg <- read.table(regFile, header = T, sep = '\t')

new_df <- data.frame(FA_reg = df_reg$FA, FA_exp = df_explore$FA)
new_df$Point <- c(1:51)
new_df$Hemisphere <- rep(c('L', 'R'), c(51, 51))


myfunc <- function(df) {
  df$FA_exp <- rev(df$FA_exp)
  df
}
new_new_df <- ddply(new_df, 'Hemisphere', myfunc)

# plotfunc <- function(df) {
#   df_melt <- melt(df, id = c('Point', 'Hemisphere'))
#   df_melt$variable <- factor(df_melt$variable)
#   p <- ggplot(df_melt, aes(x = Point, y = value, color = variable))
#   dev.new()
#   print(p + geom_line())
#   df
# }
# 
# ddply(new_new_df, 'Hemisphere', plotfunc)

FDfunc <- function(df) {
  FD <- sum(abs(df$FA_reg - df$FA_exp))/nrow(df)
  return(FD)
}

FD_out <- new_new_df %>% group_by(Hemisphere) %>% do(FD = FDfunc(.))