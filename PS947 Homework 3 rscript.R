# Homework Assignment 3

# Question 1
# the link to the public github repository is:
# https://github.com/rajasveee/MSc-Cog-Neuro--Neuropsych-PS947-23-24

#------------#
# Question 2

# loading the necessary libraries
library(tidyverse)
library(brms)
library(rstan)
library(ggplot2)

# setting the working directory
setwd("C:/Users/veepe/OneDrive/Documents")

# fetching the data- recommendations.csv
data_recom <- read.csv("recommendations.csv")

# for insights into the data:
head(data_recom)
summary(data_recom)

# fitting the bayesian statistics model
model_bayes <- brm(RecommendationFollowed ~ Mode,
             data = data_recom,
             family = bernoulli(),
             chains = 4,
             cores = 4)

summary(model_bayes)
plot(model_bayes)

#-> from the model, we can qualitatively assess whether there is an
# evidence for recomm. mode affecting choice.
#-> the model uses a logistic framework (bernoulli) with the logit function
# including one predictor- Mode with Auditory and Visual as the two levels
#-> here the intercept is representative of the baseline log odds for recomm
# when the Mode is Auditory
#-> additionally, the ModeVisual coef represents the change in log odss when Mode
# is Visual as compared to Auditory
#-> the estimated intercept is 0.06 with a credible interval (bayesian stats) of
# [-0.09, 0.20], suggesting that when the recomm mode is Auditory, the log odds of
# recomm are slightly positive but close to zero
#-> the estimated coef for ModeVisual is -0.49 with credible interval of [-0.69,
# -0.28], indicating that the when the recomm mode is Visual, a decrease in the
# log odds of the recomm is seen as compared to when it is Auditory

#-> based on the model summary, the qualitative evidence may also suggest that 
# recomm mode may affect choice
#-> the negative coef for ModeVisual indicates that on avg individuals are less 
# likely to follow recomm when presented visually than auditorily
#-> but it should also be essential to take into consideration the practical sig
# of the effect with the statistical sig
#-> a further investigation may be necessary and useful in understanding the context
# & implications


#-> to assess the perception of recomm in one modality as more competent, intelligent
# thoughtful, the statistical summary for each of these variables can be compared
# based on the Mode variable

summary_stats <- data_recom %>%
  group_by(Mode) %>%
  summarize(mean_competence = mean(Competent), 
            mean_intelligence = mean(Intelligent),
            mean_thoughtfulness = mean(Thoughtful))

ggplot(data_recom, aes(x = Mode, y = Competent)) + geom_boxplot() +
  labs(title = "Distribution of Competence Ratings by Modality")
ggplot(data_recom, aes(x = Mode, y = Intelligent)) + geom_boxplot() +
  labs(title = "Distribution of Intelligence Ratings by Modality")
ggplot(data_recom, aes(x = Mode, y = Thoughtful)) +geom_boxplot() +
  labs(title = "Distribution of Thoughtfulness Ratings by Modality")

#----------------#
# Question 3

# creating a tibble for the student data with id and marks
std_data <- tibble(
  std_id = 1:20,
  marks = c(72, 68, 44, 73, 63, 56, 80, 43, 65, 75, 15, 58, 84, 70, 78, 55, 62, 67, 48, 82))

# defining the prior distribution for the bayes model- intercept and sigma
priors <- c(
  prior(normal(0,1), class = "Intercept"),
  prior(exponential(1), class = "sigma"))

# fitting a bayesian statistics model for the student data
model_std <- brm(marks ~ std_id, data = std_data, prior = priors)

# summarising the fitted bayes model
summary(model_std)

# defining the parameters for the beta distribution prior
alpha <- 2
beta <- 2

# generating the prior predictions using the beta dist
prior_pred <- rbeta(1000, alpha, beta)

# creating a prior data frame for plotting
prior_data <- data.frame(
  x = seq(0, 1, length.out = 100), 
  y = apply(matrix(rbeta(100 * 1000, alpha, beta), nrow = 100), 1, mean),
  ymin = apply(matrix(rbeta(100 * 1000, alpha, beta), nrow = 100), 1, quantile, probs = 0.025),
  ymax = apply(matrix(rbeta(100 * 1000, alpha, beta), nrow = 100), 1, quantile, probs = 0.975))

# creating a plot for the prior predictions
prior_plot <- ggplot(prior_data, aes(x = x, y = y)) +
  geom_ribbon(aes(ymin = ymin, ymax = ymax), fill = "blue", alpha = 0.5) +
  stat_smooth(method = "lm", formula = y ~ x, se = FALSE, color = "lightblue") +
  labs(title = "Prior Predictions with stat smooth and ribbon", x = "x", y = "Prediction") +
  theme_minimal()

# generating posterior predictions from the fitted bayes model
posterior_pred <- posterior_predict(model, draws = 1000)

#calculating the means and quantiles for posterior
posterior_means <- apply(posterior_pred, 2, mean)
posterior_quantiles <- apply(posterior_pred, 2, quantile, probs = c(0.025, 0.975))

# creating a posterior data frame for plotting as well
posterior_data <- data.frame(
  x = std_data$std_id, 
  y = posterior_means,
  ymin = posterior_quantiles[1, ],
  ymax = posterior_quantiles[2, ])

# creating a plot for posterior predictions
posterior_plot <- ggplot(posterior_data, aes(x = x, y = y)) +
  geom_line(color = "lightblue", size = 1) +
  stat_smooth(aes(ymin = ymin, ymax = ymax), fill = "blue", alpha = 0.5) +
  labs(title = "Posterior Predictions", x = "Student ID", y = "Prediction") +
  theme_minimal()

# printing both the prior and posterior predictions
print(prior_plot)
print(posterior_plot)

#-> the intercept above represents the expected marl when the student id s zero
# and the coef indicates the changes in markks associated with one unit increase
# in studnet id
#-> sd/sigma is representative of the variabilty of marks around the reg line
#-> in summary, the implementation of the bayes model helps in understanding the 
# relationship between student marks and student id, providing an estimate of the 
# model parameters and the uncertainty for inference
