#! /usr/bin/Rscript

## Lib utilizadas
library(stringr)
library(dplyr)
library(plyr)
library(RCurl)
library(rjson)

## Obtener planes de apertura
inst  <- readLines("urls.txt")
all_plans <- c()

for(i in 1:length(inst)){
## Obtener planes
plan <- fromJSON(getURL(inst[i]))
    ## Construir plan
    plan  <- plan[[4]]
    names <- laply(plan, function(t)t <- t$name)
    desc  <- laply(plan, function(t)t <- t$description)
    date  <- laply(plan, function(t)t <- t$publish_date)
    dep   <- str_split(inst[i],"/")[[1]][4]
    dep   <- rep(dep,length(plan))
    ## Integrar
    data_plan <- data.frame(dep = dep, name = names, desc = desc, date = date)
    all_plans <- rbind(all_plans, data_plan)
}

write.csv(all_plans, "plans.csv", row.names = FALSE)
