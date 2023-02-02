

################
## CLEAN DATA ##
################

library(ggplot2)
library(dplyr)
library(knitr)
library(patchwork)

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

## We see that most of the easy questions come from A-SSE.A. However, all difficulty levels contain A-SSE.A in
## abundance. It would be interesting to examine what makes a question easy vs. hard in A-SSE.A.

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

#######################################
## EXAMINE WHAT MAKES QUESTIONS HARD ##
#######################################


#######################################
############### A-APR #################
#######################################

a <- filter(df, Standard.Cluster == "A-APR.A")
b <- filter(df, Standard.Cluster == "A-APR.B")


## CLEAN AND STANDARDIZE ##

library(tm)

q_corpus.a <-
        VCorpus(VectorSource(a$Question.Text))

q_corpus.b <-
        VCorpus(VectorSource(b$Question.Text))

## LOWER CASE ##

q_corpus.a <-
        tm_map(q_corpus.a, content_transformer(tolower))

q_corpus.b <-
        tm_map(q_corpus.b, content_transformer(tolower))

## Remove Numbers ##

q_corpus.a <- tm_map(q_corpus.a, removeNumbers)

q_corpus.b<- tm_map(q_corpus.b, removeNumbers)

## REMOVE STOP WORDS ##

q_corpus.a <- tm_map(q_corpus.a, removeWords, stopwords())

q_corpus.b <- tm_map(q_corpus.b, removeWords, stopwords())

# remove punctuation #

replacePunctuation <- function(x) {
        gsub("[[:punct:]]+", " ", x)
}

q_corpus.a <-
        tm_map(q_corpus.a, replacePunctuation)

q_corpus.b <-
        tm_map(q_corpus.b, replacePunctuation)

#  remove white spaces #

q_corpus.a <- tm_map(q_corpus.a , stripWhitespace)

q_corpus.b <- tm_map(q_corpus.b , stripWhitespace)

# convert to plain text #

q_corpus.a <- tm_map(q_corpus.a, PlainTextDocument)

q_corpus.b <- tm_map(q_corpus.b, PlainTextDocument)

# create Document Term Matrix #

q_dtm.a <- DocumentTermMatrix(q_corpus.a)

q_dtm.b <- DocumentTermMatrix(q_corpus.b)

## HEIRARCHAL CLUSTERING OF TEXT ##

library(cluster)
library(clValid)

d <- dist(t(q_dtm.a), method = "euclidian")
fit.a <- hclust(d=d, method = "complete")
plot(fit.a, hang = -1, main = "A-APR.A")
groups <- cutree(fit.a, k = 7)   # "k=" defines the number of clusters you are using
rect.hclust(fit.a, k = 7, border = "red") # draw dendogram with red borders around the 6 clusters
dunn(d, groups)


d <- dist(t(q_dtm.b), method = "euclidian")
fit.b <- hclust(d=d, method = "complete")
plot(fit.b, hang = -1, main = "A-APR.B")
groups <- cutree(fit.b, k = 4)   # "k=" defines the number of clusters you are using
rect.hclust(fit.b, k = 4, border = "red") # draw dendogram with red borders around the 6 clustersa.
dunn(d, groups)


#######################################
############### A-REI #################
#######################################

a <- filter(df, Standard.Cluster == "A-REI.A")
b <- filter(df, Standard.Cluster == "A-REI.B")
c <- filter(df, Standard.Cluster == "A-REI.C")
d <- filter(df, Standard.Cluster == "A-REI.D")


## CLEAN AND STANDARDIZE ##

library(tm)

q_corpus.a <-
        VCorpus(VectorSource(a$Question.Text))

q_corpus.b <-
        VCorpus(VectorSource(b$Question.Text))

q_corpus.c <-
        VCorpus(VectorSource(c$Question.Text))

q_corpus.d <-
        VCorpus(VectorSource(d$Question.Text))

## LOWER CASE ##

q_corpus.a <-
        tm_map(q_corpus.a, content_transformer(tolower))

q_corpus.b <-
        tm_map(q_corpus.b, content_transformer(tolower))

q_corpus.c <-
        tm_map(q_corpus.c, content_transformer(tolower))

q_corpus.d <-
        tm_map(q_corpus.d, content_transformer(tolower))

## Remove Numbers ##

q_corpus.a <- tm_map(q_corpus.a, removeNumbers)

q_corpus.b<- tm_map(q_corpus.b, removeNumbers)

q_corpus.c <- tm_map(q_corpus.c, removeNumbers)

q_corpus.d<- tm_map(q_corpus.d, removeNumbers)

## REMOVE STOP WORDS ##

q_corpus.a <- tm_map(q_corpus.a, removeWords, stopwords())

q_corpus.b <- tm_map(q_corpus.b, removeWords, stopwords())

q_corpus.c <- tm_map(q_corpus.c, removeWords, stopwords())

q_corpus.d <- tm_map(q_corpus.d, removeWords, stopwords())


# remove punctuation #

replacePunctuation <- function(x) {
        gsub("[[:punct:]]+", " ", x)
}

q_corpus.a <-
        tm_map(q_corpus.a, replacePunctuation)

q_corpus.b <-
        tm_map(q_corpus.b, replacePunctuation)

q_corpus.c <-
        tm_map(q_corpus.c, replacePunctuation)

q_corpus.d <-
        tm_map(q_corpus.d, replacePunctuation)

#  remove white spaces #

q_corpus.a <- tm_map(q_corpus.a , stripWhitespace)

q_corpus.b <- tm_map(q_corpus.b , stripWhitespace)

q_corpus.c <- tm_map(q_corpus.c , stripWhitespace)

q_corpus.d <- tm_map(q_corpus.d , stripWhitespace)

# convert to plain text #

q_corpus.a <- tm_map(q_corpus.a, PlainTextDocument)

q_corpus.b <- tm_map(q_corpus.b, PlainTextDocument)

q_corpus.c <- tm_map(q_corpus.c, PlainTextDocument)

q_corpus.d <- tm_map(q_corpus.d, PlainTextDocument)

# create Document Term Matrix #

q_dtm.a <- DocumentTermMatrix(q_corpus.a)

q_dtm.b <- DocumentTermMatrix(q_corpus.b)

q_dtm.c <- DocumentTermMatrix(q_corpus.c)

q_dtm.d <- DocumentTermMatrix(q_corpus.d)

## HEIRARCHAL CLUSTERING OF TEXT ##

library(cluster)
library(clValid)

# for (x in 2:50) {
#         d <- dist(t(q_dtm.c), method = "euclidian")
#         fit.c <- hclust(d=d, method = "complete")
#         plot(fit.c, hang = -1, main = "A-REI.C")
#         groups <- cutree(fit.c, k = x)   # "k=" defines the number of clusters you are using
#         rect.hclust(fit.c, k = x, border = "red") # draw dendogram with red borders around the 6 clusters
#         cat("X:", x, "dunn:", dunn(d, groups), "" )
# }

# A-REI.A #
d <- dist(t(q_dtm.a), method = "euclidian")
fit.a <- hclust(d=d, method = "complete")
plot(fit.a, hang = -1, main = "A-REI.A")
groups <- cutree(fit.a, k = 5)   # "k=" defines the number of clusters you are using
rect.hclust(fit.a, k = 5, border = "red") # draw dendogram with red borders around the 6 clusters
dunn(d, groups)

# A-REI.B #
d <- dist(t(q_dtm.b), method = "euclidian")
fit.b <- hclust(d=d, method = "complete")
plot(fit.b, hang = -1, main = "A-REI.B")
groups <- cutree(fit.b, k = 13)   # "k=" defines the number of clusters you are using
rect.hclust(fit.b, k = 13, border = "red") # draw dendogram with red borders around the 6 clusters.
dunn(d, groups)

# A-REI.C #
d <- dist(t(q_dtm.c), method = "euclidian")
fit.c <- hclust(d=d, method = "complete")
plot(fit.c, hang = -1, main = "A-REI.C")
groups <- cutree(fit.c, k = 16)   # "k=" defines the number of clusters you are using
rect.hclust(fit.c, k = 16, border = "red") # draw dendogram with red borders around the 6 clusters
dunn(d, groups)

# A-REI.D #
d <- dist(t(q_dtm.d), method = "euclidian")
fit.d <- hclust(d=d, method = "complete")
plot(fit.d, hang = -1, main = "A-REI.D")
groups <- cutree(fit.d, k = 9)   # "k=" defines the number of clusters you are using
rect.hclust(fit.d, k = 9, border = "red") # draw dendogram with red borders around the 6 clusters.
dunn(d, groups)




#######################################
############### A-SSE #################
#######################################

# a <- filter(df, Standard.Cluster == "A-SSE.A")
# b <- filter(df, Standard.Cluster == "A-SSE.B")

a <- filter(easy, Standard.Cluster == "A-SSE.A")
b <- filter(hard, Standard.Cluster == "A-SSE.A")

## CLEAN AND STANDARDIZE ##

library(tm)

q_corpus.a <-
        VCorpus(VectorSource(a$Question.Text))

q_corpus.b <-
        VCorpus(VectorSource(b$Question.Text))



## LOWER CASE ##

q_corpus.a <-
        tm_map(q_corpus.a, content_transformer(tolower))

q_corpus.b <-
        tm_map(q_corpus.b, content_transformer(tolower))

## Remove Numbers ##

q_corpus.a <- tm_map(q_corpus.a, removeNumbers)

q_corpus.b<- tm_map(q_corpus.b, removeNumbers)

## REMOVE STOP WORDS ##

q_corpus.a <- tm_map(q_corpus.a, removeWords, stopwords())

q_corpus.b <- tm_map(q_corpus.b, removeWords, stopwords())

# remove punctuation #

replacePunctuation <- function(x) {
        gsub("[[:punct:]]+", " ", x)
}

q_corpus.a <-
        tm_map(q_corpus.a, replacePunctuation)

q_corpus.b <-
        tm_map(q_corpus.b, replacePunctuation)

#  remove white spaces #

q_corpus.a <- tm_map(q_corpus.a , stripWhitespace)

q_corpus.b <- tm_map(q_corpus.b , stripWhitespace)

# convert to plain text #

q_corpus.a <- tm_map(q_corpus.a, PlainTextDocument)

q_corpus.b <- tm_map(q_corpus.b, PlainTextDocument)

# create Document Term Matrix #

q_dtm.a <- DocumentTermMatrix(q_corpus.a)
q_dtm.a

q_dtm.b <- DocumentTermMatrix(q_corpus.b, control=list(bounds = list(global = c(1, Inf))))
q_dtm.b

# library(topicmodels)
# library(ldatuning)
# 
# topicmodel <- LDA(q_dtm.a, k=3, method="Gibbs")
# tmresult <- posterior(topicmodel)
# 
# attributes(tmresult)
# beta <- tmresult$terms
# dim(beta)
# 
# terms(topicmodel, 10)
# ## HEIRARCHAL CLUSTERING OF TEXT ##
# library(cluster)
# library(clValid)

# for (x in 2:50) {
#         d <- dist(t(q_dtm.b), method = "euclidian")
#         fit.b <- hclust(d=d, method = "complete")
#         plot(fit.b, hang = -1, main = "A-SSE.B hard")
#         groups <- cutree(fit.b, k = x)   # "k=" defines the number of clusters you are using
#         rect.hclust(fit.b, k = x, border = "red") # draw dendogram with red borders around the 6 clustersa.
#         cat("X:", x, "dunn:", dunn(d, groups), "" )
# }

d <- dist(t(q_dtm.a), method = "euclidian")
fit.a <- hclust(d=d, method = "complete")
plot(fit.a, hang = -1, main="A-SSE.A easy")
groups <- cutree(fit.a, k = 9)   # "k=" defines the number of clusters you are using
rect.hclust(fit.a, k = 9, border = "red") # draw dendogram with red borders around the 6 clusters
dunn(d, groups)
findAssocs(q_dtm.a, terms = c("leading", "product", "rate", "area", "tickets"), corlimit = 0.4)

d <- dist(t(q_dtm.b), method = "euclidian")
fit.b <- hclust(d=d, method = "complete")
plot(fit.b, hang = -1, main = "A-SSE.B hard")
groups <- cutree(fit.b, k = 10)   # "k=" defines the number of clusters you are using
rect.hclust(fit.b, k = 10, border = "red") # draw dendogram with red borders around the 6 clustersa.
dunn(d, groups)
findAssocs(q_dtm.b, terms = c("value", "hours", "expressed", "identify"), corlimit= .4)


#######################################
############### F-BF ##################
#######################################

a <- filter(df, Standard.Cluster == "F-BF.A")
b <- filter(df, Standard.Cluster == "F-BF.B")


## CLEAN AND STANDARDIZE ##

library(tm)

q_corpus.a <-
        VCorpus(VectorSource(a$Question.Text))

q_corpus.b <-
        VCorpus(VectorSource(b$Question.Text))



## LOWER CASE ##

q_corpus.a <-
        tm_map(q_corpus.a, content_transformer(tolower))

q_corpus.b <-
        tm_map(q_corpus.b, content_transformer(tolower))

## Remove Numbers ##

q_corpus.a <- tm_map(q_corpus.a, removeNumbers)

q_corpus.b<- tm_map(q_corpus.b, removeNumbers)

## REMOVE STOP WORDS ##

q_corpus.a <- tm_map(q_corpus.a, removeWords, stopwords())

q_corpus.b <- tm_map(q_corpus.b, removeWords, stopwords())

# remove punctuation #

replacePunctuation <- function(x) {
        gsub("[[:punct:]]+", " ", x)
}

q_corpus.a <-
        tm_map(q_corpus.a, replacePunctuation)

q_corpus.b <-
        tm_map(q_corpus.b, replacePunctuation)

#  remove white spaces #

q_corpus.a <- tm_map(q_corpus.a , stripWhitespace)

q_corpus.b <- tm_map(q_corpus.b , stripWhitespace)

# convert to plain text #

q_corpus.a <- tm_map(q_corpus.a, PlainTextDocument)

q_corpus.b <- tm_map(q_corpus.b, PlainTextDocument)

# create Document Term Matrix #

q_dtm.a <- DocumentTermMatrix(q_corpus.a, control=list(bounds = list(global = c(1, Inf))))
q_dtm.a

q_dtm.b <- DocumentTermMatrix(q_corpus.b, control=list(bounds = list(global = c(1, Inf))))
q_dtm.b



# for (x in 2:50) {
#         d <- dist(t(q_dtm.b), method = "euclidian")
#         fit.b <- hclust(d=d, method = "complete")
#         plot(fit.b, hang = -1, main = "F-BF.B")
#         groups <- cutree(fit.b, k = x)   # "k=" defines the number of clusters you are using
#         rect.hclust(fit.b, k = x, border = "red") # draw dendogram with red borders around the 6 clustersa.
#         cat("X:", x, "dunn:", dunn(d, groups), "" )
# }

d <- dist(t(q_dtm.a), method = "euclidian")
fit.a <- hclust(d=d, method = "complete")
plot(fit.a, hang = -1, main="F-BF.A")
groups <- cutree(fit.a, k = 13)   # "k=" defines the number of clusters you are using
rect.hclust(fit.a, k = 13, border = "red") # draw dendogram with red borders around the 6 clusters
dunn(d, groups)
findAssocs(q_dtm.a, terms = c("ammount", "determine", "rate","yield"), corlimit= 0.4)

d <- dist(t(q_dtm.b), method = "euclidian")
fit.b <- hclust(d=d, method = "complete")
plot(fit.b, hang = -1, main = "F-BF.B")
groups <- cutree(fit.b, k = 2)   # "k=" defines the number of clusters you are using
rect.hclust(fit.b, k = 2, border = "red") # draw dendogram with red borders around the 6 clustersa.
dunn(d, groups)
findAssocs(q_dtm.b, terms = c("function", "line", "expression", "shifted"), corlimit= 0.4)

###########################
##########= F-IF ##########
###########################

a <- filter(df, Standard.Cluster == "F-IF.A")
b <- filter(df, Standard.Cluster == "F-IF.B")
c <- filter(df, Standard.Cluster == "F-IF.C")

## CLEAN AND STANDARDIZE ##

library(tm)

q_corpus.a <-
        VCorpus(VectorSource(a$Question.Text))

q_corpus.b <-
        VCorpus(VectorSource(b$Question.Text))

q_corpus.c <-
        VCorpus(VectorSource(c$Question.Text))


## LOWER CASE ##

q_corpus.a <-
        tm_map(q_corpus.a, content_transformer(tolower))

q_corpus.b <-
        tm_map(q_corpus.b, content_transformer(tolower))

q_corpus.c <-
        tm_map(q_corpus.c, content_transformer(tolower))



## Remove Numbers ##

q_corpus.a <- tm_map(q_corpus.a, removeNumbers)

q_corpus.b<- tm_map(q_corpus.b, removeNumbers)

q_corpus.c <- tm_map(q_corpus.c, removeNumbers)



## REMOVE STOP WORDS ##

q_corpus.a <- tm_map(q_corpus.a, removeWords, stopwords())

q_corpus.b <- tm_map(q_corpus.b, removeWords, stopwords())

q_corpus.c <- tm_map(q_corpus.c, removeWords, stopwords())




# remove punctuation #

replacePunctuation <- function(x) {
        gsub("[[:punct:]]+", " ", x)
}

q_corpus.a <-
        tm_map(q_corpus.a, replacePunctuation)

q_corpus.b <-
        tm_map(q_corpus.b, replacePunctuation)

q_corpus.c <-
        tm_map(q_corpus.c, replacePunctuation)



#  remove white spaces #

q_corpus.a <- tm_map(q_corpus.a , stripWhitespace)

q_corpus.b <- tm_map(q_corpus.b , stripWhitespace)

q_corpus.c <- tm_map(q_corpus.c , stripWhitespace)



# convert to plain text #

q_corpus.a <- tm_map(q_corpus.a, PlainTextDocument)

q_corpus.b <- tm_map(q_corpus.b, PlainTextDocument)

q_corpus.c <- tm_map(q_corpus.c, PlainTextDocument)



# create Document Term Matrix #

q_dtm.a <- DocumentTermMatrix(q_corpus.a, control=list(bounds = list(global = c(2, Inf))))

q_dtm.b <- DocumentTermMatrix(q_corpus.b)

q_dtm.c <- DocumentTermMatrix(q_corpus.c)



## HEIRARCHAL CLUSTERING OF TEXT ##

library(cluster)
library(clValid)

# for (x in 2:50) {
#         d <- dist(t(q_dtm.c), method = "euclidian")
#         fit.c <- hclust(d=d, method = "complete")
#         plot(fit.c, hang = -1, main = "F-IF.C")
#         groups <- cutree(fit.c, k = x)   # "k=" defines the number of clusters you are using
#         rect.hclust(fit.c, k = x, border = "red") # draw dendogram with red borders around the 6 clusters
#         cat("X:", x, "dunn:", dunn(d, groups), "" )
# }

# F-IF.A #
d <- dist(t(q_dtm.a), method = "euclidian")
fit.a <- hclust(d=d, method = "complete")
plot(fit.a, hang = -1, main = "F-IF.A")
groups <- cutree(fit.a, k = 3)   # "k=" defines the number of clusters you are using
rect.hclust(fit.a, k = 3, border = "red") # draw dendogram with red borders around the 6 clusters
dunn(d, groups)

# F-IF.B #
d <- dist(t(q_dtm.b), method = "euclidian")
fit.b <- hclust(d=d, method = "complete")
plot(fit.b, hang = -1, main = "F-IF.B")
groups <- cutree(fit.b, k = 3)   # "k=" defines the number of clusters you are using
rect.hclust(fit.b, k = 3, border = "red") # draw dendogram with red borders around the 6 clusters.
dunn(d, groups)
findAssocs(q_dtm.b, terms = c("line", "represent"), corlimit= 0.4)


# F-IF.C #
d <- dist(t(q_dtm.c), method = "euclidian")
fit.c <- hclust(d=d, method = "complete")
plot(fit.c, hang = -1, main = "F-IF.C")
groups <- cutree(fit.c, k = 13)   # "k=" defines the number of clusters you are using
rect.hclust(fit.c, k = 13, border = "red") # draw dendogram with red borders around the 6 clusters
dunn(d, groups)


#######################################
############### F-LE #################
#######################################

a <- filter(df, Standard.Cluster == "F-LE.A")
b <- filter(df, Standard.Cluster == "F-LE.B")


## CLEAN AND STANDARDIZE ##

library(tm)

q_corpus.a <-
        VCorpus(VectorSource(a$Question.Text))

q_corpus.b <-
        VCorpus(VectorSource(b$Question.Text))

## LOWER CASE ##

q_corpus.a <-
        tm_map(q_corpus.a, content_transformer(tolower))

q_corpus.b <-
        tm_map(q_corpus.b, content_transformer(tolower))

## Remove Numbers ##

q_corpus.a <- tm_map(q_corpus.a, removeNumbers)

q_corpus.b<- tm_map(q_corpus.b, removeNumbers)

## REMOVE STOP WORDS ##

q_corpus.a <- tm_map(q_corpus.a, removeWords, stopwords())

q_corpus.b <- tm_map(q_corpus.b, removeWords, stopwords())

# remove punctuation #

replacePunctuation <- function(x) {
        gsub("[[:punct:]]+", " ", x)
}

q_corpus.a <-
        tm_map(q_corpus.a, replacePunctuation)

q_corpus.b <-
        tm_map(q_corpus.b, replacePunctuation)

#  remove white spaces #

q_corpus.a <- tm_map(q_corpus.a , stripWhitespace)

q_corpus.b <- tm_map(q_corpus.b , stripWhitespace)

# convert to plain text #

q_corpus.a <- tm_map(q_corpus.a, PlainTextDocument)

q_corpus.b <- tm_map(q_corpus.b, PlainTextDocument)

# create Document Term Matrix #

q_dtm.a <- DocumentTermMatrix(q_corpus.a, control=list(bounds = list(global = c(2, Inf))))

q_dtm.b <- DocumentTermMatrix(q_corpus.b, control=list(bounds = list(global = c(2, Inf))))

## HEIRARCHAL CLUSTERING OF TEXT ##

library(cluster)
library(clValid)

# for (x in 2:50) {
#         d <- dist(t(q_dtm.b), method = "euclidian")
#         fit.b <- hclust(d=d, method = "complete")
#         plot(fit.b, hang = -1, main = "F-LE.B")
#         groups <- cutree(fit.b, k = x)   # "k=" defines the number of clusters you are using
#         rect.hclust(fit.b, k = x, border = "red") # draw dendogram with red borders around the 6 clustersa.
#         cat("X:", x, "dunn:", dunn(d, groups), "" )
# }

d <- dist(t(q_dtm.a), method = "euclidian")
fit.a <- hclust(d=d, method = "complete")
plot(fit.a, hang = -1, main = "F-LE.A")
groups <- cutree(fit.a, k = 14)   # "k=" defines the number of clusters you are using
rect.hclust(fit.a, k = 14, border = "red") # draw dendogram with red borders around the 6 clusters
dunn(d, groups)


d <- dist(t(q_dtm.b), method = "euclidian")
fit.b <- hclust(d=d, method = "complete")
plot(fit.b, hang = -1, main = "F-LE.B")
groups <- cutree(fit.b, k = 3)   # "k=" defines the number of clusters you are using
rect.hclust(fit.b, k = 3, border = "red") # draw dendogram with red borders around the 6 clustersa.
dunn(d, groups)

###########################
##########= S-ID ##########
###########################

a <- filter(df, Standard.Cluster == "S-ID.A")
b <- filter(df, Standard.Cluster == "S-ID.B")
c <- filter(df, Standard.Cluster == "S-ID.C")

## CLEAN AND STANDARDIZE ##

library(tm)

q_corpus.a <-
        VCorpus(VectorSource(a$Question.Text))

q_corpus.b <-
        VCorpus(VectorSource(b$Question.Text))

q_corpus.c <-
        VCorpus(VectorSource(c$Question.Text))


## LOWER CASE ##

q_corpus.a <-
        tm_map(q_corpus.a, content_transformer(tolower))

q_corpus.b <-
        tm_map(q_corpus.b, content_transformer(tolower))

q_corpus.c <-
        tm_map(q_corpus.c, content_transformer(tolower))



## Remove Numbers ##

q_corpus.a <- tm_map(q_corpus.a, removeNumbers)

q_corpus.b<- tm_map(q_corpus.b, removeNumbers)

q_corpus.c <- tm_map(q_corpus.c, removeNumbers)



## REMOVE STOP WORDS ##

q_corpus.a <- tm_map(q_corpus.a, removeWords, stopwords())

q_corpus.b <- tm_map(q_corpus.b, removeWords, stopwords())

q_corpus.c <- tm_map(q_corpus.c, removeWords, stopwords())




# remove punctuation #

replacePunctuation <- function(x) {
        gsub("[[:punct:]]+", " ", x)
}

q_corpus.a <-
        tm_map(q_corpus.a, replacePunctuation)

q_corpus.b <-
        tm_map(q_corpus.b, replacePunctuation)

q_corpus.c <-
        tm_map(q_corpus.c, replacePunctuation)



#  remove white spaces #

q_corpus.a <- tm_map(q_corpus.a , stripWhitespace)

q_corpus.b <- tm_map(q_corpus.b , stripWhitespace)

q_corpus.c <- tm_map(q_corpus.c , stripWhitespace)



# convert to plain text #

q_corpus.a <- tm_map(q_corpus.a, PlainTextDocument)

q_corpus.b <- tm_map(q_corpus.b, PlainTextDocument)

q_corpus.c <- tm_map(q_corpus.c, PlainTextDocument)



# create Document Term Matrix #

q_dtm.a <- DocumentTermMatrix(q_corpus.a, control=list(bounds = list(global = c(2, Inf))))

q_dtm.b <- DocumentTermMatrix(q_corpus.b)

q_dtm.c <- DocumentTermMatrix(q_corpus.c)



## HEIRARCHAL CLUSTERING OF TEXT ##

library(cluster)
library(clValid)
# 
# for (x in 2:50) {
#         d <- dist(t(q_dtm.c), method = "euclidian")
#         fit.c <- hclust(d=d, method = "complete")
#         plot(fit.c, hang = -1, main = "S-ID.C")
#         groups <- cutree(fit.c, k = x)   # "k=" defines the number of clusters you are using
#         rect.hclust(fit.c, k = x, border = "red") # draw dendogram with red borders around the 6 clusters
#         cat("X:", x, "dunn:", dunn(d, groups), "" )
# }

# S-ID.A #
d <- dist(t(q_dtm.a), method = "euclidian")
fit.a <- hclust(d=d, method = "complete")
plot(fit.a, hang = -1, main = "S-ID.A")
groups <- cutree(fit.a, k = 8)   # "k=" defines the number of clusters you are using
rect.hclust(fit.a, k = 8, border = "red") # draw dendogram with red borders around the 6 clusters
dunn(d, groups)

# S-ID.B #
d <- dist(t(q_dtm.b), method = "euclidian")
fit.b <- hclust(d=d, method = "complete")
plot(fit.b, hang = -1, main = "S-ID.B")
groups <- cutree(fit.b, k = 10)   # "k=" defines the number of clusters you are using
rect.hclust(fit.b, k = 10, border = "red") # draw dendogram with red borders around the 6 clusters.
dunn(d, groups)


# S-ID.C #
d <- dist(t(q_dtm.c), method = "euclidian")
fit.c <- hclust(d=d, method = "complete")
plot(fit.c, hang = -1, main = "S-ID.C")
groups <- cutree(fit.c, k = 17)   # "k=" defines the number of clusters you are using
rect.hclust(fit.c, k = 17, border = "red") # draw dendogram with red borders around the 6 clusters
dunn(d, groups)
