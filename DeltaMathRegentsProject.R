

################
## CLEAN DATA ##
################

library(dplyr)

df <- read.csv("dmathdata.csv", header = TRUE)
df <- subset(df, select=-c(X, X.1))

df <- na.omit(df)

attach(df)

df.table <- df %>% select(Question.Number, Standard, Percentage.Correct)
df.table <- slice(df.table, c(5,24,23,75,38,11))

library(gt)
library(gtExtras)

library(knitr)
kable(df.table, format= "markdown")

########################################
## CLASSIFY DATA BY PERCENTAGE CORRECT ##
########################################

library(BAMMtools)
breaks <- getJenksBreaks(df$Percentage.Correct, 4)
breaks

##############################
## RECLASSIFY BY DIFFICULTY ##
##############################

hard <- filter(df, Percentage.Correct >= breaks[1] & 
                       Percentage.Correct < breaks[2])

normal <- filter(df, Percentage.Correct >= breaks[2] & 
                         Percentage.Correct < breaks[3])

easy <- filter(df, Percentage.Correct >= breaks[3] & 
                       Percentage.Correct < breaks[4])

df <- mutate(df, Difficulty = 
                     case_when(Percentage.Correct >= breaks[1] & 
                                       Percentage.Correct < breaks[2] ~ "Hard",
                               Percentage.Correct >= breaks[2] & 
                                       Percentage.Correct < breaks[3] ~ "Normal",
                               Percentage.Correct >= breaks[3] & 
                                       Percentage.Correct <= breaks[4] ~ "Easy"))


diff.df <- data.frame(c("Easy", "Normal", "Hard"), c(mean(easy$Percentage.Correct*100), 
                                                     mean(normal$Percentage.Correct*100), 
                                                     mean(hard$Percentage.Correct*100)))

colnames(diff.df) <- c("Difficulty", "Percentage Correct (Mean)")

kable(diff.df)


df.table.diff <- df %>% select(Question.Number, Standard, Percentage.Correct, Difficulty )
df.table.diff <- slice(df.table.diff, c(5,24,23,75,38,11))
kable(df.table.diff)

###########
## PLOTS ##
###########


## COMPARING STANDARD VS DIFFICULTY LEVELS ##

library(patchwork)
library(ggplot2)

easy.plot <- ggplot(data = easy, aes(x=Standard)) + 
        geom_bar(aes(fill = Standard, y= (..count..)/sum(..count..))) + 
        labs(title = "Easy", x="", y="Percent") + 
        guides(fill="none") + 
        scale_y_continuous(breaks = c(0, .10, .20, .3), 
                           labels=c("0%", "10%", "20%", "30%"),
                           limits = c(0,.35)) 

normal.plot <- ggplot(data = normal, aes(x=Standard)) + 
        geom_bar(aes(fill = Standard, y= (..count..)/sum(..count..))) + 
        labs(title="Normal", x="", y="Percent") +
        guides(fill="none") + 
        scale_y_continuous(breaks = c(0, .10, .20, .3), 
                           labels=c("0%", "10%", "20%", "30%"),
                           limits = c(0,.35))

hard.plot <- ggplot(data = hard, aes(x=Standard)) + 
        geom_bar(aes(fill = Standard, y= (..count..)/sum(..count..))) + 
        labs(title = "Hard", x="", y="Percent") + 
        guides(fill="none") + 
        scale_y_continuous(breaks = c(0, .10, .20, .3), 
                           labels=c("0%", "10%", "20%", "30%"),
                           limits = c(0,.35)) + 
        scale_x_discrete(limits = c("A-APR", "A-CED", "A-REI", "A-SSE", "F-BF", "F-IF", "F-LE", "N-Q", "N-RN", "S-ID"))



design <- c(
        area(10,10),
        area(10,10),
        area(10,10)
        
)

plot.1 <- easy.plot / normal.plot/ hard.plot + 
        plot_annotation(theme = theme_gray(base_family = 'mono'),
                        title = "Distribution of Standards across Difficulty Levels")

plot.1

## EXAMINING F-IF MORE CLOSELY ##

library(dplyr)
hard.IF <- filter(hard, Standard == "F-IF")
normal.IF <- filter(normal, Standard == "F-IF")
easy.IF <- filter(easy, Standard == "F-IF")

plot.1 <- ggplot(data = easy.IF, aes(x=Standard.Cluster)) + 
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) + 
        labs(title = "Easy", x="", y="Percent") + 
        guides(fill="none") +
        scale_y_continuous(breaks = c(0, .20, .40, .6), labels = c("0%", "20%", "40%", "60%")) +
        scale_x_discrete(limits = c("F-IF.A", "F-IF.B", "F-IF.C"))

plot.2 <- ggplot(data = normal.IF, aes(x=Standard.Cluster)) + 
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) + 
        labs(title = "Normal", x="", y="Percent") + 
        guides(fill="none") +
        scale_y_continuous(breaks = c(0, .20, .40, .6), labels = c("0%", "20%", "40%", "60%"))

plot.3 <- ggplot(data = hard.IF, aes(x=Standard.Cluster)) + 
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) + 
        labs(title = "Hard", x="", y="Percent") + 
        guides(fill="none") +
        scale_y_continuous(breaks = c(0, .20, .40, .6), labels = c("0%", "20%", "40%", "60%"))

fig <- plot.1 / plot.2 / plot.3  + 
        plot_annotation(theme = theme_gray(base_family = 'mono'),
                        title = "Distribution of F-IF Standard across Difficulty Levels")
fig

