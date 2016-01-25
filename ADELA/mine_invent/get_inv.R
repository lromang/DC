#! /usr/bin/Rscript

###################################################
## Libraries
###################################################
## Manipulate dates
suppressPackageStartupMessages(library(lubridate))
## Manipulate strings
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(stringdist))
## Manipulate data
suppressPackageStartupMessages(library(plyr))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(data.table))
## Graphics
suppressPackageStartupMessages(library(ggplot2))
## Read in data
suppressPackageStartupMessages(library(gdata))
suppressPackageStartupMessages(library(readxl))
suppressPackageStartupMessages(library(xlsx))
suppressPackageStartupMessages(library(foreign))

## In order to execute this script,
## One must first execute the script ../../DGM/webService.R

## ---------------------------------
## Read in data
## ---------------------------------
data <- read.csv("../../DGM/MAT.csv", stringsAsFactors = FALSE)

## ---------------------------------
## Filter inventories
## ---------------------------------
inventories <- dplyr::filter(
    data,
    str_detect(rec,
               "Inventario Institucional")
)

## ---------------------------------
## Get URLs
## ---------------------------------
urls <- inventories$rec_url

## ---------------------------------
## Build data.frame with all inventories
## ---------------------------------
all_inv <- c()
for(i in 1:length(urls)){
    rec_pub  <- 0
    rec_priv <- 0
    rec_res  <- 0
    ## Download inventory
    download_url <- paste0("wget --output-document test.xlsx ",
                          urls[i])
    system(download_url)
    ## Convert to csv
    system("ssconvert test.xlsx test.csv")
    inv <- tryCatch(
    {
            read.csv("test.csv", stringsAsFactors = FALSE)
        },
        error=function(cond) {
            message(cond)
            # Choose a return value in case of error
            return(data.frame(a = NA))
        }
    )
    ## Remove data
    system("rm test*")
    ## Test if data makes sense
    if(ncol(inv) >=  5){
    class_inv <- tolower(str_trim(inv[,5]))
    class_inv <- str_replace_all(class_inv, ".*blico.*", "público")
    class_inv <- str_replace_all(class_inv, ".*rivado.*", "privado")
    class_inv <- str_replace_all(class_inv, ".*tringido.*", "restringido")
    class_inv <- plyr::count(class_inv)
    ## Test for matches
    if(str_detect(class_inv$x, "blico") == TRUE){
        rec_pub <-
            class_inv$freq[str_detect(class_inv$x,
                                      "blico")]
    }
    if(str_detect(class_inv$x, "rivado") == TRUE){
        rec_priv <-
            class_inv$freq[str_detect(class_inv$x,
                                      "rivado")]
    }
    if(str_detect(class_inv$x, "tringido") == TRUE){
        rec_res <-
            class_inv$freq[str_detect(class_inv$x,
                                      "tringido")]
    }
    ## Build data frame for dep
    d_class_inv <- data.frame(dep = inventories$dep[i],
                         rec_pub  = rec_pub,
                         rec_priv = rec_priv,
                         rec_res  = rec_res
                         )
    ## Build general data frame
    all_inv <- rbind(all_inv, d_class_inv)
    }else{
        d_class_inv <- data.frame(dep = inventories$dep[i],
                                 rec_pub  = NA,
                                 rec_priv = NA,
                                 rec_res  = NA
                                 )
        all_inv <- rbind(all_inv, d_class_inv)
    }
}
write.csv(all_inv, "class_rec_inv.csv", row.names = FALSE)
