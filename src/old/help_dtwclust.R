# use the date from the timeseries_plots.Rmd & timeseries_plots.Rmd
# https://medium.com/@panda061325/stock-clustering-with-time-series-clustering-in-r-63fe1fabe1b6
# https://barrypan.github.io/Stock-Clustering/Stock_Analysis.html

library(quantmod)

ts.wide <- ts.up.diff %>%
  select(date, LAD19NM, diff) %>%
  filter(date > "2020-3-1")

ts.wide <- ts.up %>%
  select(date, LAD19NM, mean.up ) %>%
  filter(date > "2019-12-31")

ts.wide <- ts.down.diff %>%
  select(date, LAD19NM, diff )

ts.wide <- ts.tests.diff %>%
  select(date, LAD19NM, diff )

# create time series
library(tsbox)
ts.wide <- ts_wide(ts.wide)

# dtwclust
library(dtwclust)

# from vignette
# Linear reinterpolation to same length
data <- reinterpolate(CharTraj, new.length = max(lengths(CharTraj)))
# z-normalization
data <- zscore(data[60L:100L])
head(data)

pc_dtw <- tsclust(data, k = 4L, seed = 8L,
                  distance = "dtw_basic", centroid = "dba",
                  norm = "L2", window.size = 20L)
pc_dtw

pc_ks <- tsclust(data, k = 4L, seed = 8L,
                 distance = "sbd", centroid = "shape")
pc_tp <- tsclust(data, k = 4L, type = "tadpole", seed = 8L,
                 control = tadpole_control(dc = 1.5, window.size = 20L))

# not working
sapply(list(DTW = pc_dtw, kShape = pc_ks, TADPole = pc_tp),
       cvi, b = CharTrajLabels[60L:100L], type = "VI")

#
data <- CharTraj[1L:20L]
pc_k <- tsclust(data, k = 3L:5L, seed = 94L,
                distance = "dtw_basic", centroid = "pam")

# normalized stock price
normalized = function(x){
  m = mean(x)
  s = sd(x)
  n = (x-m)/s
  return(n)
}
ts.wide_ = lapply(ts.wide[,-1],function(x) normalized(x))
ts.wide_ <- as.data.frame(ts.wide_)

ts.wide_ <- ts.wide_ %>%
  map(function(x) normalized(x))
ts.wide_$date <- NULL

library(imputeTS)
# impute with means
ts.wide <- na_mean(ts.wide)
sapply(ts.wide, function(x) sum(is.na(x)))


# upload working hours and days

ts.wide <- ts.up %>%
  select(date, LAD19NM, mean.up) %>%
  filter(date > "2020-2-15")

# turn to a wide format
ts.wide <- ts_wide(ts.wide)

# impute with means
library(imputeTS)
ts.wide <- na_mean(ts.wide)
sapply(ts.wide, function(x) sum(is.na(x)))

# extract names
ts.wide.names <- names(ts.wide[,-1])
ts.wide <- ts.wide[,-1]

# standardise
ts.wide <- zscore(ts.wide)

# convert to list for tsclust
ts.wide <- split(ts.wide, rep(1:ncol(ts.wide), each = nrow(ts.wide)))

# 5 - 20 cluster sollutions
pc_k <- tsclust(ts.wide, k = c(5,10,15,20), seed = 94L,
                type="partitional",
                distance = "dtw_basic", centroid = "pam", trace = T, 
                args = tsclust_args(dist = list(window.size = 20L)))

# decide k, see RJ-2019-023 for max/min
names(pc_k) <- paste0("k_", c("5","10","15", "20"))
sapply(pc_k, cvi, type = "internal")

# I need to work on the selection

pc_k <- tsclust(ts.wide, k = 20, seed = 94L, 
                type="partitional", 
                distance = "dtw_basic", centroid = "pam", trace = T, 
                args = tsclust_args(dist = list(window.size = 20L)))


plot(pc_k)

cluster_up <- data.frame(LAD=ts.wide.names,
                           cluster=pc_k@cluster)


# downlad working hours and days

ts.wide <- ts.down %>%
  select(date, LAD19NM, mean.down) %>%
  filter(date > "2020-2-15")

# turn to a wide format
ts.wide <- ts_wide(ts.wide)

# impute with means
library(imputeTS)
ts.wide <- na_mean(ts.wide)
sapply(ts.wide, function(x) sum(is.na(x)))

# extract names
ts.wide.names <- names(ts.wide[,-1])
ts.wide <- ts.wide[,-1]

# standardise
ts.wide <- zscore(ts.wide)

# convert to list for tsclust
ts.wide <- split(ts.wide, rep(1:ncol(ts.wide), each = nrow(ts.wide)))

# 5 - 20 cluster sollutions
pc_k <- tsclust(ts.wide, k = c(5,10,15,20), seed = 94L,
                type="partitional",
                distance = "dtw_basic", centroid = "pam", trace = T, 
                args = tsclust_args(dist = list(window.size = 20L)))

# decide k, see RJ-2019-023 for max/min
names(pc_k) <- paste0("k_", c("5","10","15", "20"))
sapply(pc_k, cvi, type = "internal")

# I need to work on the selection

pc_k <- tsclust(ts.wide, k = 20, seed = 94L, 
                type="partitional", 
                distance = "dtw_basic", centroid = "pam", trace = T, 
                args = tsclust_args(dist = list(window.size = 20L)))


plot(pc_k)

cluster_down <- data.frame(LAD=ts.wide.names,
                         cluster=pc_k@cluster)


# tests working hours and days

ts.wide <- ts.tests %>%
  select(date, LAD19NM, n.tests) %>%
  filter(date > "2020-2-15")

# turn to a wide format
ts.wide <- ts_wide(ts.wide)

# impute with means
library(imputeTS)
ts.wide <- na_mean(ts.wide)
sapply(ts.wide, function(x) sum(is.na(x)))

# extract names
ts.wide.names <- names(ts.wide[,-1])
ts.wide <- ts.wide[,-1]

# standardise
ts.wide <- zscore(ts.wide)

# convert to list for tsclust
ts.wide <- split(ts.wide, rep(1:ncol(ts.wide), each = nrow(ts.wide)))

# 5 - 20 cluster sollutions
pc_k <- tsclust(ts.wide, k = c(5,10,15,20), seed = 94L,
                type="partitional",
                distance = "dtw_basic", centroid = "pam", trace = T, 
                args = tsclust_args(dist = list(window.size = 20L)))

# decide k, see RJ-2019-023 for max/min
names(pc_k) <- paste0("k_", c("5","10","15", "20"))
sapply(pc_k, cvi, type = "internal")

# I need to work on the selection

pc_k <- tsclust(ts.wide, k = 15, seed = 94L, 
                type="partitional", 
                distance = "dtw_basic", centroid = "pam", trace = T, 
                args = tsclust_args(dist = list(window.size = 20L)))


plot(pc_k)

cluster_tests <- data.frame(LAD=ts.wide.names,
                           cluster=pc_k@cluster)

head(cluster_tests)

clusters <- merge(cluster_up, cluster_down, by = "LAD")
names(clusters)[2] <- "cluster.up"
names(clusters)[3] <- "cluster.down"
clusters <- merge(clusters, cluster_tests, by = "LAD")
names(clusters)[4] <- "cluster.tests"
sapply(clusters, function(x) sum(is.na(x)))
head(clusters)
pr