library(ggplot2)

d <- ggplot(aes(x = cyl, y = mpg), data=mtcars)

d <- d + geom_point() +  stat_summary(fun.y = mean, color = 'red', geom = 'point')
