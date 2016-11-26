library(ggplot2)

df1 <- data.frame(a = rep(seq(1, 10), 2),
                  b = c(seq(0.1, 1, 0.1), rnorm(10)), 
                  alpha = factor(rep(c(1, 0.5), c(10, 10))))

g <- guide_legend('title')
p1 <- ggplot(aes(x = a, y = b, colour = alpha, alpha = alpha,
                 size = alpha),
             data = df1)
p1 <- p1 + geom_point() + scale_colour_manual(values = c('red','blue')) + 
  scale_size_manual(values = c(1.5, 1)) + 
  guides(colour = g, size = g, alpha = g)
# 
# DF <- data.frame(
#   x = rnorm(100, mean = 0, sd = 1),
#   y = rnorm(n = 100, mean = 1, sd = 1),
#   color = sample(
#     x = c('red', 'blue'), size = 100, replace = T, prob = c(.5,.5)
#   ),
#   alpha = runif(n = 100, min = 0.1, max = 1)
# )
# 
# p <- DF %>%
#   ggplot(aes(
#     x = x, y = y, color = color, size = 2, alpha = alpha
#   )) +
#   geom_point(show.legend  = TRUE) + theme_bw() +
#   scale_size(guide = FALSE) +
#   scale_color_discrete(guide = FALSE)