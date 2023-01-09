library(dplyr)
library(magrittr)
library(ggplot2)
library(Hmisc)
library(corrplot)
library(tidyr)

data <- read.csv('data/final_dataset.csv')

# clean data
data %<>%
  mutate(fellow_accuracy_rating = case_when(fellow_accuracy_rating == 'Poor' ~ 0,
                                            fellow_accuracy_rating == 'Fair' ~ 1,
                                            fellow_accuracy_rating == 'Good' ~ 2, 
                                            fellow_accuracy_rating == 'Excellent' ~ 3))

data %<>%
  rename('computer_sentiment' = sentiment,
         'computer_magnitude' = magnitude)

data %<>%
  mutate(category = case_when(category == 'Advertising' ~ 'Commercials',
                              category == 'Legal/Court' ~ 'Court Proceedings'))

# compute & visualize correlations and significance
correlations <- rcorr(as.matrix(select(data, runtime, year, fellow_accuracy_rating, automl_confidence_avg, computer_sentiment, human_sentiment, war, bleu_score)))

# all correlations
jpeg("viz/correlations.jpg", width = 600, height = 600)
corrplot(correlations$r,
         method = "number",
         type = "lower",
         tl.col = 'black',
         tl.srt = 45)
dev.off()

# only significant correlations
jpeg("viz/correlation_significance.jpg", width = 600, height = 600)
corrplot(correlations$r,
         method = "number",
         type = "lower",
         tl.col = 'black',
         tl.srt = 45,
         p.mat = correlations$P,
         insig = 'blank')
dev.off()

# different types of accuracy by video category

# create significance dataframe for facet labeling 
f_labels_avg_accuracy <- data.frame(accuracy_type = c("fellow_accuracy_rating", "automl_confidence_avg", "war", "bleu_score"), 
                       label = c(paste("p =", round(t.test(data$fellow_accuracy_rating~data$category)$p.value, 5)),
                                 paste("p =", round(t.test(data$automl_confidence_avg~data$category)$p.value, 5)),
                                 paste("p =", round(t.test(data$war~data$category)$p.value, 5)),
                                 paste("p =", round(t.test(data$bleu_score~data$category)$p.value, 5))),
                       y = c(max(data$fellow_accuracy_rating, na.rm = TRUE),
                             max(data$automl_confidence_avg, na.rm = TRUE),
                             max(data$war, na.rm = TRUE),
                             max(data$bleu_score, na.rm = TRUE))
                       )

data %>%
  select(category, fellow_accuracy_rating, automl_confidence_avg, war, bleu_score) %>%
  pivot_longer(cols = c("fellow_accuracy_rating", "automl_confidence_avg", "war", "bleu_score"), 
               names_to = "accuracy_type",
               values_to = "accuracy_score") %>%
  group_by(category, accuracy_type) %>%
  summarise(avg_accuracy = mean(accuracy_score, na.rm = TRUE)) %>%
  ggplot() +
  geom_col(aes(category, avg_accuracy, fill = category)) +
  scale_fill_manual(values = c("#109648", "#c1d9cdff")) +
  facet_wrap(~accuracy_type, scales = "free") +
  geom_text(aes(1.5, y, label = label), data = f_labels_avg_accuracy, size = 3, color = "#5A5A5A") +
  theme_minimal() +
  labs(y = "Average Accuracy", 
       x = "Video Type", 
       fill = "Video Type",
       title = "Transcript accuracy by video type")

ggsave(filename = "viz/accuracy_by_category.jpg", width = 7, height = 5)

# sentiment by video category

# reshape the dataframe to make sentiment type a variable

data_sentiment <- data %>%
  select(category, human_sentiment, computer_sentiment) %>%
  pivot_longer(cols = c("human_sentiment", "computer_sentiment"), 
               names_to = "transcript_type",
               values_to = "sentiment_score")

# create significance dataframe for labeling

f_labels_sentiment <- data_sentiment %>% 
  group_by(category) %>% 
  summarise(label = paste("p =", t.test(sentiment_score ~ transcript_type)$p.value), 
            y = max(sentiment_score))

data %>%
  select(category, human_sentiment, computer_sentiment) %>%
  pivot_longer(cols = c("human_sentiment", "computer_sentiment"), 
               names_to = "transcript_type",
               values_to = "sentiment_score") %>%
  group_by(category) %>%
  mutate(pval = t.test(sentiment_score ~ transcript_type)$p.value) %>%
  group_by(category, transcript_type, pval) %>%
  summarise(avg_sentiment = mean(sentiment_score, na.rm = TRUE)) %>%
  ggplot() +
  geom_bar(aes(category, avg_sentiment, group = transcript_type, fill = transcript_type), position = "dodge", stat = "identity") +
  geom_text(position = position_dodge(width = 0.9), aes(category, avg_sentiment+0.01, fill = transcript_type, label = round(avg_sentiment, 2))) +
  scale_fill_manual(values = c("#109648", "#c1d9cdff")) +
  geom_text(aes(category, max(avg_sentiment), label = paste("p =", round(pval, 3))), size = 3, color = "#5A5A5A") +
  theme_minimal() +
  theme(legend.position = "bottom") +
  labs(y = "Average Sentiment",
       x = "Video Type",
       fill = "Transcript Type",
       title = "How does sentiment differ between computer and human transcripts?",
       subtitle = "By video type")

ggsave(filename = "viz/sentiment_by_category.jpg", width = 7, height = 4)

# does average year differ by category?
# data %>%
#   group_by(category) %>%
#   summarise(avg_year = mean(year, na.rm = TRUE))


# is there a year of accuracy improvement? is it different by category?
data %>%
  select(category, year, fellow_accuracy_rating, automl_confidence_avg, war, bleu_score) %>%
  mutate(decade = case_when(year >= 1950 & year < 1960 ~ '1950s',
                            year >= 1960 & year < 1970 ~ '1960s',
                                  year >= 1970 & year < 1980 ~ '1970s',
                                  year >= 1980 & year < 1990 ~ '1980s',
                                  year >= 1990 & year < 2000 ~ '1990s',
                                  year >= 2000 & year < 2010 ~ '2000s')) %>%
  filter(!is.na(decade)) %>%
  pivot_longer(cols = c("fellow_accuracy_rating", "automl_confidence_avg", "war", "bleu_score"), 
               names_to = "accuracy_type",
               values_to = "accuracy_score") %>%
  group_by(decade, category, accuracy_type) %>%
  summarise(avg_accuracy = mean(accuracy_score, na.rm = TRUE)) %>%
  ggplot() +
  geom_point(aes(decade, avg_accuracy, color = accuracy_type, group = accuracy_type)) +
  geom_line(aes(decade, avg_accuracy, color = accuracy_type, group = accuracy_type)) +
  facet_wrap(~category) +
  theme_minimal() +
  scale_color_manual(values = c("#182825", "#c1d9cdff", "#109648", "#48BEFF")) +
  labs(x = "Decade", 
       y = "Average Accuracy", 
       color = "Accuracy Type",
       title = "Transcript accuracy over time", 
       subtitle = "By score type and video type")

ggsave(filename = "viz/accuracy_over_time_by_category.jpg", width = 6, height = 4)

# is there a year of accuracy improvement? is it different by category?
data %>%
  select(year, fellow_accuracy_rating, automl_confidence_avg, war, bleu_score) %>%
  mutate(decade = case_when(year >= 1950 & year < 1960 ~ '1950s',
                            year >= 1960 & year < 1970 ~ '1960s',
                            year >= 1970 & year < 1980 ~ '1970s',
                            year >= 1980 & year < 1990 ~ '1980s',
                            year >= 1990 & year < 2000 ~ '1990s',
                            year >= 2000 & year < 2010 ~ '2000s')) %>%
  filter(!is.na(decade)) %>%
  pivot_longer(cols = c("fellow_accuracy_rating", "automl_confidence_avg", "war", "bleu_score"), 
               names_to = "accuracy_type",
               values_to = "accuracy_score") %>%
  group_by(decade, accuracy_type) %>%
  summarise(avg_accuracy = mean(accuracy_score, na.rm = TRUE)) %>%
  ggplot() +
  geom_point(aes(decade, avg_accuracy, color = accuracy_type, group = accuracy_type)) +
  geom_line(aes(decade, avg_accuracy, color = accuracy_type, group = accuracy_type)) +
  theme_minimal() +
  scale_color_manual(values = c("#182825", "#c1d9cdff", "#109648", "#48BEFF")) +
  labs(x = "Decade", 
       y = "Average Accuracy", 
       color = "Accuracy Type",
       title = "Transcript accuracy over time", 
       subtitle = "By score type and video type")
  
ggsave(filename = "viz/accuracy_over_time.jpg", width = 6, height = 4)

# significance of correlations

cor.test(data$year, data$war)
cor.test(data$year, data$fellow_accuracy_rating)
cor.test(data$year, data$automl_confidence_avg)
cor.test(data$bleu_score, data$automl_confidence_avg)

t.test(data$war~data$category)
t.test(data$fellow_accuracy_rating~data$category)
t.test(data$war~data$category)
t.test(data$war~data$category)

t.test(data$computer_sentiment ~ data$category)
t.test(data$human_sentiment ~ data$category)
  

  



