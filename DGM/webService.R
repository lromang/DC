#! /usr/bin/Rscript

source("./ultimate.R")

## Select fields of interest.
filter_data <- dplyr::select(all_data, one_of("dep", "slug", "conj","rec","rec_des","rec_url"))
filter_data <- dplyr::filter(filter_data, slug != "NA")
write.csv(filter_data, "./filter_data.csv", row.names = FALSE)
