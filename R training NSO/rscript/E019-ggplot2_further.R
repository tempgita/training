#----------------------------------------------------------------------------
# ggplot2 further
#----------------------------------------------------------------------------
library(ggplot2)
library(mosaicData)

# mapping color = sex in geom_point instead in ggplot function
ggplot(data = CPS85, mapping = aes(x = exper, y = wage)) + 
  geom_point(mapping = aes(color = sex), alpha = 0.3, size = 2) +
  geom_smooth(method = 'lm') +
  theme_bw()

#mapping aes in geom_point and geom_smooth
ggplot(data = CPS85, mapping = aes(x = exper, y = wage)) + 
  geom_point(mapping = aes(color = sex), alpha = 0.3, size = 2) +
  geom_smooth(mapping = aes(linetype = sex, color = sex), method = 'lm') +
  theme_bw()

#storing the plot in an object
myplot <- ggplot(data = CPS85, mapping = aes(x = exper, y = wage)) + 
  geom_point(mapping = aes(color = sex), alpha = 0.3, size = 2) +
  geom_smooth(mapping = aes(linetype = sex, color = sex), method = 'lm') +
  theme_bw()
myplot

#Saving the plot
ggsave(filename = 'myplot.jpg')
ggsave(filename = 'myplot.pdf')
ggsave(filename = 'myplot.png')

ggsave(filename = 'myplot.jpg', plot = myplot, units = 'cm', width = 20, height = 16)
ggsave(filename = 'myplot.pdf', plot = myplot, units = 'cm', width = 20, height = 16)
ggsave(filename = 'myplot.png', plot = myplot, units = 'cm', width = 20, height = 16)
