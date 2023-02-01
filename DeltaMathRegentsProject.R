

################
## CLEAN DATA ##
################

library(dplyr)
library(knitr)

df <- read.csv("deltamathexcel.csv", header = TRUE)

df <- na.omit(df)

attach(df)

df.table <- df %>% select(Question.Number, Standard, Percentage.Correct)
df.table <- slice(df.table, c(5,24,23,75,38,11))

library(gt)
library(gtExtras)

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

# full percent ##

full.percent.plot <- ggplot(data = df, aes(x=Standard)) + 
        geom_bar(aes(fill = Standard, y= (..count..)/sum(..count..))) + 
        labs(title = "", x="", y="Percent") + 
        guides(fill="none") +
        scale_y_continuous(limits=c(0, .3), labels=c("0%", "10%", "20%", "30%"))

full.percent.plot + 
        plot_annotation(theme = theme_gray(base_family = 'mono'),
                        title = "Test Percentage by Standard")

## difficulty percentage ##

diff.percent.plot <- ggplot(data = df, aes(x=factor(Difficulty, level = c("Easy", "Normal", "Hard")))) + 
        geom_bar(aes(fill = Difficulty, y= (..count..)/sum(..count..))) + 
        labs(title = "", x="", y="Percent") + 
        guides(fill="none") +
        scale_y_continuous(labels = scales::percent)

diff.percent.plot + 
        plot_annotation(theme = theme_gray(base_family = 'mono'),
                        title = "Test Percentage by Difficulty")

percent.df <- data.frame(c("Easy", "Normal", "Hard"), c("22%", "45%", "33%"))
colnames(percent.df) <- c("Difficulty", "Percentage")
percent.df
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


plot.1 <- easy.plot / normal.plot/ hard.plot + 
        plot_annotation(theme = theme_gray(base_family = 'mono'),
                        title = "Distribution of Standards across Difficulty Levels")

plot.1

##################################
## EXAMINING SPECIFIC STANDARDS ##
##################################

## A-APR ##

library(dplyr)
hard.APR <- filter(hard, Standard == "A-APR")
normal.APR <- filter(normal, Standard == "A-APR")
easy.APR <- filter(easy, Standard == "A-APR")

plot.1 <- ggplot(data = easy.APR, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Easy", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))

plot.2 <- ggplot(data = normal.APR, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Normal", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))

plot.3 <- ggplot(data = hard.APR, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Hard", x="", y="Percent") +
        guides(fill="none")  +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))

APR.PLOT <- plot.1 / plot.2 / plot.3  +
        plot_annotation(theme = theme_gray(base_family = 'mono'),
                        title = "Distribution of A-APR Standard across Difficulty Levels")
APR.PLOT 

## A-CED skip since only A-CED.A ##

## A-REI ##

hard.REI <- filter(hard, Standard == "A-REI")
normal.REI <- filter(normal, Standard == "A-REI")
easy.REI <- filter(easy, Standard == "A-REI")

plot.1 <- ggplot(data = easy.REI, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Easy", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))

plot.2 <- ggplot(data = normal.REI, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Normal", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))
        

plot.3 <- ggplot(data = hard.REI, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Hard", x="", y="Percent") +
        guides(fill="none")+
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))

REI.PLOT <- plot.1 / plot.2 / plot.3  +
        plot_annotation(theme = theme_gray(base_family = 'mono'),
                        title = "Distribution of A-REI Standard across Difficulty Levels")
REI.PLOT 

## A-SSE ##

hard.SSE <- filter(hard, Standard == "A-SSE")
normal.SSE <- filter(normal, Standard == "A-SSE")
easy.SSE <- filter(easy, Standard == "A-SSE")

plot.1 <- ggplot(data = easy.SSE, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Easy", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))

plot.2 <- ggplot(data = normal.SSE, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Normal", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))


plot.3 <- ggplot(data = hard.SSE, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Hard", x="", y="Percent") +
        guides(fill="none")+
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))

SSE.PLOT <- plot.1 / plot.2 / plot.3  +
        plot_annotation(theme = theme_gray(base_family = 'mono'),
                        title = "Distribution of A-SSE Standard across Difficulty Levels")
SSE.PLOT 

## F-BF ##

hard.BF <- filter(hard, Standard == "F-BF")
normal.BF <- filter(normal, Standard == "F-BF")
easy.BF <- filter(easy, Standard == "F-BF")

plot.1 <- ggplot(data = easy.BF, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Easy", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))

plot.2 <- ggplot(data = normal.BF, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Normal", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))


plot.3 <- ggplot(data = hard.BF, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Hard", x="", y="Percent") +
        guides(fill="none")+
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))

BF.PLOT <- plot.1 / plot.2 / plot.3  +
        plot_annotation(theme = theme_gray(base_family = 'mono'),
                        title = "Distribution of F-BF Standard across Difficulty Levels")
BF.PLOT 

## F-IF ##

hard.IF <- filter(hard, Standard == "F-IF")
normal.IF <- filter(normal, Standard == "F-IF")
easy.IF <- filter(easy, Standard == "F-IF")

plot.1 <- ggplot(data = easy.IF, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Easy", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))

plot.2 <- ggplot(data = normal.IF, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Normal", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))


plot.3 <- ggplot(data = hard.IF, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Hard", x="", y="Percent") +
        guides(fill="none")+
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))

IF.PLOT <- plot.1 / plot.2 / plot.3  +
        plot_annotation(theme = theme_gray(base_family = 'mono'),
                        title = "Distribution of F-IF Standard across Difficulty Levels")
IF.PLOT 

## F-LE ##

hard.LE <- filter(hard, Standard == "F-LE")
normal.LE <- filter(normal, Standard == "F-LE")
easy.LE <- filter(easy, Standard == "F-LE")

plot.1 <- ggplot(data = easy.LE, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Easy", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))

plot.2 <- ggplot(data = normal.LE, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Normal", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))


plot.3 <- ggplot(data = hard.LE, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Hard", x="", y="Percent") +
        guides(fill="none")+
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%")) +
        scale_x_discrete(limits=c("F-LE.A", "F-LE.B"))

LE.PLOT <- plot.1 / plot.2 / plot.3  +
        plot_annotation(theme = theme_gray(base_family = 'mono'),
                        title = "Distribution of F-LE Standard across Difficulty Levels")
LE.PLOT 

## S-ID ##

hard.ID <- filter(hard, Standard == "S-ID")
normal.ID <- filter(normal, Standard == "S-ID")
easy.ID <- filter(easy, Standard == "S-ID")

plot.1 <- ggplot(data = easy.ID, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Easy", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))+
        scale_x_discrete(limits=c("S-ID.A", "S-ID.B", "S-ID.C"))

plot.2 <- ggplot(data = normal.ID, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Normal", x="", y="Percent") +
        guides(fill="none") +
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))


plot.3 <- ggplot(data = hard.ID, aes(x=Standard.Cluster)) +
        geom_bar(aes(fill = Standard.Cluster, y= (..count..)/sum(..count..))) +
        labs(title = "Hard", x="", y="Percent") +
        guides(fill="none")+
        scale_y_continuous(limits=c(0, 1), labels=c("0%", "25%", "50%", "75%", "100%"))

ID.PLOT <- plot.1 / plot.2 / plot.3  +
        plot_annotation(theme = theme_gray(base_family = 'mono'),
                        title = "Distribution of S-ID Standard across Difficulty Levels")
ID.PLOT 


