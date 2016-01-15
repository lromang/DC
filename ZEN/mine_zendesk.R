#! /usr/bin/Rscript

library(plyr)
library(stringr)
library(tidyr)
library(dplyr)

##############################
## Read in data
##############################
usr <- readLines("users.txt")
sat <- readLines("satisfaction_ratings.txt")
org <- readLines("organizations.txt")
tic <- readLines("tickets.txt")

##############################
## structure user
##############################
## requester
requester <- usr[str_detect(usr, "requester")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## name
name <- usr[str_detect(usr, "u_name:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## role
role <- usr[str_detect(usr, "role:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## org_usr
org_usr <- usr[str_detect(usr, "org:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## email
email <- usr[str_detect(usr, "email:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## datauser
data_usr <- data.frame(requester = requester,
                       name = name,
                       role = role,
                       id_org = org_usr,
                       email = email)

##############################
## structure satisfaction
##############################
## requester
sat_requester <- sat[str_detect(sat, "requester_id:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## score
score <- sat[str_detect(sat, "score:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## score
comment <- sat[str_detect(sat, "comment:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## date
date <- sat[str_detect(sat, "date:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim() %>% as.Date()

data_sat <- data.frame(requester = sat_requester,
                      score = score,
                      comment = comment,
                      date = date)

##############################
## structure org
##############################
## id_org
id_org <- org[str_detect(org, "id:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## id_org
org_s_name <- org[str_detect(org, " name:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## org_name
org_name <- org[str_detect(org, "org_name:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

data_org <- data.frame(id_org = id_org,
                      org_s_name = org_s_name,
                      org_name = org_name)

##############################
## structure ticket
##############################
## Id
tic_id <- tic[str_detect(tic, " id:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## Organization
tic_dep <- tic[str_detect(tic, "organization:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## Requester
tic_request <- tic[str_detect(tic, "requester:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## Date
tic_date <- tic[str_detect(tic, " date: ")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim() %>% as.Date()

## Subject
tic_sub <- tic[str_detect(tic, "subject:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## Message
tic_des <- tic[str_detect(tic, "description:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## Tag
tic_tag <- tic[str_detect(tic, "tags:")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()

## Stat
tic_stat <- tic[str_detect(tic, " status: ")] %>%
    lapply(function(t)t <- str_split(t, ":")[[1]][2]) %>%
    unlist() %>% str_replace(",","") %>% str_trim()


## is disqus
## is_disq <- str_detect(tic_tag, "disqus")

tic_data <- data.frame(id         = tic_id,
                      stat       = tic_stat,
                      id_org     = tic_dep,
                      requester  = tic_request,
                      date       = tic_date,
                      subject    = tic_sub,
                      descript   = tic_des,
                      tag        = tic_tag)

## merge results disqus
## usr_org <- merge(data_org, data_usr, by = "id_org")
tic_org <- merge(data_org, tic_data,  by = "id_org")
write.csv(tic_org, "tic.csv", row.names = FALSE)

##############################
## putting all together
##############################
## satisfaction usr
sat_usr <- merge(data_sat, data_usr, by = "requester")

## satisfaction usr org
sat_usr_org <- merge(sat_usr, data_org, by = "id_org")

## final data
final_data <- sat_usr_org[,-c(1,2)]
final_data <- final_data[,c(4,5,6,7,1,2)]

## Write results
write.csv(final_data, "zendesk.csv", row.names = FALSE)
