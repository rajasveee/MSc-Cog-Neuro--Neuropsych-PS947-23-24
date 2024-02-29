# Load necessary libraries
library(tidyverse)
library(brms)
library(rstan)

# Set working directory
setwd("C:/Users/veepe/OneDrive/Documents")

data_recom <- read.csv("recommendations.csv")

head(data_recom)
summary(data_recom)
#Bayesian regression model
model <- brm(RecommendationFollowed ~ Mode,
             data = data_recom,
             family = bernoulli(),
             chains = 4,
             cores = 4)

summary(model)
plot(model)