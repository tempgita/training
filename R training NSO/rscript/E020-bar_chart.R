library(ggplot2)
data(Arthritis, package="vcd")

#simple bar chart
table(Arthritis$Improved)

ggplot(Arthritis, aes(x=Improved)) + geom_bar() +
  labs(title="Simple Bar chart", 
       x="Improvement",
       y="Frequency") +
  theme_bw()

#Horizontal bar chart
ggplot(Arthritis, aes(x=Improved)) + geom_bar() +
  labs(title="Simple Bar chart", 
       x="Improvement",
       y="Frequency") +
  coord_flip()+
  theme_bw()

#Stacked bar chart
table(Arthritis$Improved, Arthritis$Treatment)

ggplot(Arthritis, aes(x=Treatment, fill = Improved)) + 
  geom_bar(position = 'stack') +
  labs(title="Simple Bar chart", 
       x="Improvement",
       y="Frequency") +
  theme_bw()

#Grouped bar chart
ggplot(Arthritis, aes(x=Treatment, fill = Improved)) + 
  geom_bar(position = 'dodge') +
  labs(title="Simple Bar chart", 
       x="Improvement",
       y="Frequency") +
  theme_bw()

#Filled bar chart
ggplot(Arthritis, aes(x=Treatment, fill = Improved)) + 
  geom_bar(position = 'fill') +
  labs(title="Simple Bar chart", 
       x="Improvement",
       y="Proportion") +
  theme_bw()

#managing congested labels 
ggplot(mpg, aes(x=model)) +
  geom_bar() #produce congested labels

ggplot(mpg, aes(x=model)) +
  geom_bar() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
#OR
ggplot(mpg, aes(x=model)) +
  geom_bar() +
  coord_flip()
