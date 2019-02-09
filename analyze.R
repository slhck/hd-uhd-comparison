# Data Analysis script for HD/UHD comparison.
#
# Author: Werner Robitza <werner.robitza@gmail.com>
# License: MIT

library(tidyverse)
library(ggthemes)
library(forcats)
library(RColorBrewer)
library(coin)
library(stats)
library(magrittr)
library(broom)
library(moments)
library(evaluate)

options(scipen=9999)

# ===================================================================
# DATA READING AND PREP

d = read.csv("results.csv") %>% 
  mutate_at(c("experiment", "subject", "rating_type", "label_shown", "condition"), as.factor)

d.subject_mapping = d %>% select(subject, rating_type, label_shown) %>% unique

d.questionnaire = read.csv("questionnaire.csv") %>%
  gather(subject, answer, starts_with("X")) %>%
  filter(question != "type") %>% 
  filter(question != "label_shown") %>% 
  mutate(subject = gsub("X", "", subject)) %>%
  mutate_at("subject", as.factor) %>% 
  left_join(d.subject_mapping)

# Create factors
d$rating_str %<>%
  factor(levels = c("much worse", "worse", "slightly worse", "same", "slightly better", "better", "much better"))

# ===================================================================
# DATA ENRICHMENT

# add usage of "same"
d %<>% left_join(
  d %>% 
    group_by(rating_type, label_shown, subject, rating_str) %>%
    tally() %>%
    complete(rating_str, fill = list(n = 0)) %>%
    filter(rating_str == "same") %>%
    select(-rating_str) %>% 
    rename(rating_same_cnt = n)
)

# add skewness of ratings
d %<>%
  group_by(rating_type, label_shown, subject) %>% 
  mutate(rating_skew = skewness(rating)) %>%
  ungroup()

# ===================================================================
# STATISTICAL TESTS

# Calculate stats
d.statistical_comparison = d %>%
  group_by(label_shown, rating_type) %>%
  nest %>% 
  mutate(
    anova = map(data, .f = ~ aov(rating ~ condition, data = .)),
    tukey = map(anova, .f = ~ TukeyHSD(.) %>% tidy),
    anova_tidy = map(anova, tidy),
    pairwise_bonf = map(data, .f = ~ pairwise.t.test(.$rating, .$condition, p.adj = "bonf") %>% tidy),
    pairwise_holm = map(data, .f = ~ pairwise.t.test(.$rating, .$condition, p.adj = "holm") %>% tidy)
  )

# ANOVA
d.anova = d.statistical_comparison %>% 
  unnest(anova_tidy) %>% 
  mutate(
    p.value = round(p.value, 3),
    significant = ifelse(p.value < 0.05, TRUE, FALSE)
  ) %>% 
  filter(term == "condition")

# Tukey HSD
d.tukey = d.statistical_comparison %>%
  unnest(tukey) %>% 
  mutate(
    p.value.tukey = round(adj.p.value, 3)
  ) %>% 
  select(-term, -estimate, -starts_with("conf"), -adj.p.value) %>% 
  separate(comparison, into = c("c1", "c2")) %>% 
  mutate_at(vars(c1, c2), as.integer) %>% 
  arrange(label_shown, rating_type, c2)

# Bonferroni
d.bonf = d.statistical_comparison %>% 
  unnest(pairwise_bonf) %>% 
  mutate(
    p.value.bonf = round(p.value, 3)
  ) %>% 
  select(-p.value) %>% 
  rename(c1 = group1, c2 = group2) %>% 
  mutate_at(vars(c1, c2), as.integer)

# Holm
d.holm = d.statistical_comparison %>% 
  unnest(pairwise_holm) %>% 
  mutate(
    p.value.holm = round(p.value, 3)
  ) %>% 
  select(-p.value) %>% 
  rename(c1 = group1, c2 = group2) %>% 
  mutate_at(vars(c1, c2), as.integer)

# Combine all
d.statistical_comparison_all = d.tukey %>%
  left_join(d.holm) %>%
  left_join(d.bonf) %>% 
  mutate(
    significant = ifelse(p.value.tukey < 0.05, TRUE, FALSE)
  )

d.statistical_comparison_all
