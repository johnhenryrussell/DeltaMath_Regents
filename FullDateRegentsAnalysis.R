################
## CLEAN DATA ##
################

library(dplyr)
library(knitr)

q_raw <- read.csv("deltamathexcel.csv", stringsAsFactors = FALSE)

q_raw <- na.omit(q_raw)

attach(q_raw)

#########################################
## CLASSIFY DATA BY PERCENTAGE CORRECT ##
#########################################

library(BAMMtools)
breaks <- getJenksBreaks(q_raw$Percentage.Correct, 4)
breaks

challenging <- filter(q_raw,
                      Percentage.Correct >= breaks[1] &
                              Percentage.Correct < breaks[2])

average <- filter(q_raw,
                  Percentage.Correct >= breaks[2] &
                          Percentage.Correct < breaks[3])

straightforward <- filter(q_raw,
                          Percentage.Correct >= breaks[3] &
                                  Percentage.Correct < breaks[4])

q_raw <- mutate(
        q_raw,
        Difficulty =
                case_when(
                        Percentage.Correct >= breaks[1] &
                                Percentage.Correct < breaks[2] ~ "challenging",
                        Percentage.Correct >= breaks[2] &
                                Percentage.Correct < breaks[3] ~ "average",
                        Percentage.Correct >= breaks[3] &
                                Percentage.Correct <= breaks[4] ~ "straightforward"
                )
)


q_raw.difficulty <-
        data.frame(c("straightforward", "average", "challenging"),
                   c(
                           mean(straightforward$Percentage.Correct * 100),
                           mean(average$Percentage.Correct *
                                        100),
                           mean(challenging$Percentage.Correct *
                                        100)
                   ))

colnames(q_raw.difficulty) <-
        c("Difficulty", "Percentage Correct (Mean)")

kable(q_raw.difficulty)

## CLEAN AND STANDARDIZE TEXT DATA ##

library(tm)

q_corpus <- VCorpus(VectorSource(q_raw$Question.Text))

q_corpus.straightforward <-
        VCorpus(VectorSource(straightforward$Question.Text))
q_corpus.average <- VCorpus(VectorSource(average$Question.Text))
q_corpus.challenging <-
        VCorpus(VectorSource(challenging$Question.Text))

# transform messages to lower case #

q_corpus_clean <- tm_map(q_corpus, content_transformer(tolower))

q_corpus_clean.straightforward <-
        tm_map(q_corpus.straightforward, content_transformer(tolower))
q_corpus_clean.average <-
        tm_map(q_corpus.average, content_transformer(tolower))
q_corpus_clean.challenging <-
        tm_map(q_corpus.challenging, content_transformer(tolower))

# remove numbers #

q_corpus_clean <- tm_map(q_corpus_clean, removeNumbers)

q_corpus_clean.straightforward <-
       tm_map(q_corpus_clean.straightforward, removeNumbers)
q_corpus_clean.average <-
        tm_map(q_corpus_clean.average, removeNumbers)
q_corpus_clean.challenging <-
        tm_map(q_corpus_clean.challenging, removeNumbers)

# remove stop words #

q_corpus_clean <- tm_map(q_corpus_clean, removeWords, stopwords())

q_corpus_clean.straightforward <-
        tm_map(q_corpus_clean.straightforward, removeWords, stopwords())
q_corpus_clean.average <-
        tm_map(q_corpus_clean.average, removeWords, stopwords())
q_corpus_clean.challenging <-
        tm_map(q_corpus_clean.challenging, removeWords, stopwords())

q_corpus_clean.straightforward <-
        tm_map(
                q_corpus_clean.straightforward,
                removeWords,
               c("function", "equation", "represents", "number", "per", "can", "graph")
       )
q_corpus_clean.average <-
        tm_map(
                q_corpus_clean.average,
                removeWords,
                c("function", "equation", "represents","number", "per", "can", "graph")
        )
q_corpus_clean.challenging <-
        tm_map(
                q_corpus_clean.challenging,
                removeWords,
                c("function", "equation", "represents", "number", "per", "can", "graph")
        )

# remove punctuation #

replacePunctuation <- function(x) {
        gsub("[[:punct:]]+", " ", x)
}

q_corpus_clean <- tm_map(q_corpus_clean, replacePunctuation)

q_corpus_clean.straightforward <-
        tm_map(q_corpus_clean.straightforward, replacePunctuation)
q_corpus_clean.average <-
        tm_map(q_corpus_clean.average, replacePunctuation)
q_corpus_clean.challenging <-
        tm_map(q_corpus_clean.challenging, replacePunctuation)

#  remove white spaces #

q_corpus_clean <- tm_map(q_corpus_clean, stripWhitespace)

q_corpus_clean.straightforward <-
        tm_map(q_corpus_clean.straightforward, stripWhitespace)
q_corpus_clean.average <-
        tm_map(q_corpus_clean.average, stripWhitespace)
q_corpus_clean.challenging <-
        tm_map(q_corpus_clean.challenging, stripWhitespace)

## CREATE DTM SPARSE MATRIX ##

q_corpus_clean <- tm_map(q_corpus_clean, PlainTextDocument)

q_corpus_clean.straightforward <-
        tm_map(q_corpus_clean.straightforward, PlainTextDocument)
q_corpus_clean.average <-
        tm_map(q_corpus_clean.average, PlainTextDocument)
q_corpus_clean.challenging <-
        tm_map(q_corpus_clean.challenging, PlainTextDocument)

q_dtm <- DocumentTermMatrix(q_corpus_clean)

q_dtm.straightforward <-
        DocumentTermMatrix(q_corpus_clean.straightforward)
q_dtm.average <- DocumentTermMatrix(q_corpus_clean.average)
q_dtm.challenging <- DocumentTermMatrix(q_corpus_clean.challenging)

#######################################
## CREATE TRAINING AND TEST DATASETS ##
#######################################

sample <-
        sample(c(TRUE, FALSE),
               nrow(q_dtm),
               replace = TRUE,
               prob = c(0.75, 0.25))

q_dtm_train <- q_dtm[sample,]
q_dtm_test <- q_dtm[!sample,]

library(wordcloud)

par(mfrow = c(3, 1))
wordcloud(
        q_corpus_clean.straightforward,
        max.words = 20,
        random.order = FALSE,
        scale = c(2.5, 0.1),
        colors = brewer.pal(8, "Dark2"),
        rot.per = 0
)
wordcloud(
        q_corpus_clean.average,
        max.words = 20,
        random.order = FALSE,
        scale = c(2.5, 0.1),
        colors = brewer.pal(8, "Dark2"),
        rot.per = 0
)
wordcloud(
        q_corpus_clean.challenging,
        max.words = 20,
        random.order = FALSE,
        scale = c(2.5, 0.1),
        colors = brewer.pal(8, "Dark2"),
        rot.per = 0
)


assoc_straightforward <- findAssocs(q_dtm.straightforward, terms = findFreqTerms(q_dtm.straightforward, lowfreq = 9), corlimit= 0.3)

assoc_average <- findAssocs(q_dtm.average, terms = findFreqTerms(q_dtm.average, lowfreq = 15), corlimit= 0.3)

assoc_challenging <- findAssocs(q_dtm.challenging, terms = findFreqTerms(q_dtm.challenging, lowfreq = 9), corlimit= 0.3)

library(syuzhet)
library(lubridate)
library(ggplot2)
library(scales)
library(reshape2)
library(dplyr)

get_nrc_sentiment(q_raw$Question.Text)

