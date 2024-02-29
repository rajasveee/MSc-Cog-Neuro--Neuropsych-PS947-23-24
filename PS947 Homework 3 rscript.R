# Homework Assignment 3

# Question 1:
# the github link for the rscript file: 
# the github link for the quarto html file:


#loading the libraries
library(tidyverse)
library(brms)
library(rstan)

#setting the working directory 
setwd("C:/Users/veepe/OneDrive/Documents")

#fetching the csv data file for the data
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
