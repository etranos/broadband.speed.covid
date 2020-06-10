library(workflows)
library(parsnip)
library(recipes)
library(yardstick)
library(glmnet)
library(tidyverse)
library(tidyquant)
library(timetk) # Use >= 0.1.3, remotes::install_github("business-science/timetk")


# Add time series signature
bb2020test <- bb2020 %>% 
  select(datetext,speedup)
    
# Add time series signature
recipe_spec_timeseries <- recipe(speedup ~ ., data = bb2020test) %>%
  step_timeseries_signature(datetext) 

bb2020test_ <- bake(prep(recipe_spec_timeseries), new_data = bb2020test)
options(tibble.width = Inf) 
head(bb2020test_)

bb2020test_final <- recipe_spec_timeseries %>%
  step_rm(date) %>%
  step_rm(contains("iso"), 
          contains("second"), contains("minute"), contains("hour"),
          contains("am.pm"), contains("xts")) %>%
  step_normalize(contains("index.num"), date_year) %>%
  step_interact(~ date_month.lbl * date_day) %>%
  step_interact(~ date_month.lbl * date_mweek) %>%
  step_interact(~ date_month.lbl * date_wday.lbl * date_yday) %>%
  step_dummy(contains("lbl"), one_hot = TRUE) 

bake(prep(bb2020test_final), new_data = bb2020test_)

bake(prep(recipe_spec_final), new_data = train_tbl)

##########
# install.packages("devtools")
devtools::install_github("robjhyndman/anomalous-acm")
library(anomalousACM)

z <- ts(matrix(rnorm(3000),ncol=100),freq=4)
y <- tsmeasures(z)
biplot.features(y)
anomaly(y)

y_ <- tsmeasures(bb2020test$speedup)


########
# tsfeatures is the cran and advanced version of anomalousACM
library(tsfeatures)
ft <- tsfeatures(bb2020test$speedup)
head(ft)
dim(ft)
entropy(bb2020test$speedup)
stability(bb2020test$speedup)
lumpiness(bb2020test$speedup)
crossing_points(bb2020test$speedup)
length(bb2020test$speedup)
flat_spots(bb2020test$speedup)
hurst(bb2020test$speedup)
acf_features(bb2020test$speedup)

# reproducing Hyndman, Wang & Laptev (ICDM 2015)
yahoo <- yahoo_data()
head(yahoo)

hwl <- bind_cols(
  tsfeatures(yahoo,
             c("acf_features","entropy","lumpiness",
               "flat_spots","crossing_points")),
  tsfeatures(yahoo,"stl_features", s.window='periodic', robust=TRUE),
  tsfeatures(yahoo, "max_kl_shift", width=48),
  tsfeatures(yahoo,
             c("mean","var"), scale=FALSE, na.rm=TRUE),
  tsfeatures(yahoo,
             c("max_level_shift","max_var_shift"), trim=TRUE)) %>%
  select(mean, var, x_acf1, trend, linearity, curvature,
         seasonal_strength, peak, trough,
         entropy, lumpiness, spike, max_level_shift, max_var_shift, flat_spots,
         crossing_points, max_kl_shift, time_kl_shift)
head(hwl)

hwl.bb <- bind_cols(
  tsfeatures(bb2020test$speedup,
             c("acf_features","entropy","lumpiness",
               "flat_spots","crossing_points")),
  tsfeatures(bb2020test$speedup,"stl_features", s.window='periodic', robust=TRUE),
  tsfeatures(bb2020test$speedup, "max_kl_shift", width=48),
  tsfeatures(bb2020test$speedup,
             c("mean","var"), scale=FALSE, na.rm=TRUE),
  tsfeatures(bb2020test$speedup,
             c("max_level_shift","max_var_shift"), trim=TRUE)) %>%
  select(mean, var, x_acf1, trend, linearity, curvature,
         seasonal_strength, peak, trough,
         entropy, lumpiness, spike, max_level_shift, max_var_shift, flat_spots,
         crossing_points, max_kl_shift, time_kl_shift)
head(hwl.bb)
