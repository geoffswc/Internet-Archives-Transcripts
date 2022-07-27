library(dplyr)
library(magrittr)
library(ggplot2)
library(Hmisc)
library(gt)
library(corrplot)

data <- read.csv('final_dataset.csv')

# clean data
data %<>%
  mutate(fellow_accuracy_rating = case_when(fellow_accuracy_rating == 'Poor' ~ 0,
                                            fellow_accuracy_rating == 'Fair' ~ 1,
                                            fellow_accuracy_rating == 'Good' ~ 2, 
                                            fellow_accuracy_rating == 'Excellent' ~ 3))

# compute & visualize correlations and significance
correlations <- rcorr(as.matrix(select(data, runtime, year, fellow_accuracy_rating, automl_confidence_avg, computer_sentiment, human_sentiment, wer, bleu_score)))

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

# average WER by category
data %>%
  group_by(category) %>%
  summarise(avg_wer = mean(wer)) %>%
  ggplot() +
  geom_col(aes(x = category, y = avg_wer, fill = category)) +
  theme_minimal()

ggsave(filename = "viz/wer_by_category.jpg")

# average fellow score by category
data %>%
  group_by(category) %>%
  summarise(avg_fellow_accuracy = mean(fellow_accuracy_rating, na.rm = TRUE)) %>%
  ggplot() +
  geom_col(aes(x = category, y = avg_fellow_accuracy, fill = category)) +
  theme_minimal()

ggsave(filename = "viz/fellowscore_by_category.jpg")

# average BLEU by category
data %>%
  group_by(category) %>%
  summarise(avg_bleu = mean(bleu_score, na.rm = TRUE)) %>%
  ggplot() +
  geom_col(aes(x = category, y = avg_bleu, fill = category)) +
  theme_minimal()
  
ggsave(filename = "viz/bleu_by_category.jpg")



