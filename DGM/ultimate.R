#! /usr/bin/Rscript

##########################################
## This script mines all of ckan
##########################################

##-----------------------------
## Libraries
##-----------------------------
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(XML))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(RCurl))
suppressPackageStartupMessages(library(rjson))
suppressPackageStartupMessages(library(plyr))
suppressPackageStartupMessages(library(httr))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(RJSONIO))

##-----------------------------
## Bring all the info from ckan
## (This might take a some time)
##-----------------------------
data <-
    RJSONIO::fromJSON(
        getURL("http://catalogo.datos.gob.mx/api/3/action/current_package_list_with_resources")
    )

## We select the results
results <- data$result

## Each entry is a dataset (conjunto)
all_data <- c()
for(i in 1:length(results)){
    set <- results[[i]]
    ## Institution
    dep <- set$organization$title
    if(!is.null(dep)){
        ## Slug
        slug <- set$organization$name
        ## Conjunto
        conj    <- set$title
        if(length(set$extras)>=3){
            id_conj <- set$extras[[3]]["value"]
        }else{
            id_conj <- NA
        }
        ## Creation and modification date
        date_created <- as.Date(set$metadata_created)
        date_modif   <- as.Date(set$metadata_modified)
        ## Resources
        resources    <- set$resources
        if(!is.null(resources)){
            resource.name   <- laply(resources, function(t)t <- {if(!is.null(t$name)){t$name}else{NA}})
            resource.date   <- laply(resources, function(t)t <- {if(!is.null(t$created)){t$created}else{NA}})
            resource.url    <- laply(resources, function(t)t <- {if(!is.null(t$url)){t$url}else{NA}})
            resource.format <- laply(resources, function(t)t <- {if(!is.null(t$format)){t$format}else{NA}})
            resource.size   <- laply(resources, function(t)t <- {if(!is.null(t$size)){t$size}else{NA}})
            resource.desc   <- laply(resources, function(t)t <- {if(!is.null(t$description)){t$description}else{NA}})
        }
        n <- length(resource.name)
        all_data <- rbind(all_data,
                        data.frame(
                            dep  = rep(dep,  n),
                            slug = rep(slug, n),
                            conj = rep(conj, n),
                            conj_fecha_cre   = rep(date_created, n),
                            conj_fecha_modif = rep(date_modif, n),
                            rec        = resource.name,
                            rec_des    = resource.desc,
                            rec_fecha  = resource.date,
                            rec_url    = resource.url,
                            rec_format = resource.format,
                            rec_tam    = resource.size,
                            id_conj    = rep(id_conj,n)
                        )
                        )
    }else{
        dep   <- "grupos"
        slug  <- NA
        conj  <- set$name
        conj_fecha_cre   <- set$metadata_created
        conj_fecha_modif <- set$revision_timestamp
        ## Resources
        resources        <- set$resources
        if(!is.null(resources)){
            resource.name   <- laply(resources, function(t)t <- {if(!is.null(t$name)){t$name}else{NA}})
            resource.date   <- laply(resources, function(t)t <- {if(!is.null(t$created)){t$created}else{NA}})
            resource.url    <- laply(resources, function(t)t <- {if(!is.null(t$url)){t$url}else{NA}})
            resource.format <- laply(resources, function(t)t <- {if(!is.null(t$format)){t$format}else{NA}})
            resource.size   <- laply(resources, function(t)t <- {if(!is.null(t$size)){t$size}else{NA}})
            resource.desc   <- laply(resources, function(t)t <- {if(!is.null(t$description)){t$description}else{NA}})
        }
        n <- length(resource.name)
        all_data <- rbind(all_data,
                         data.frame(
                             slug = rep(slug, n),
                             dep  = rep(dep,  n),
                             conj = rep(conj, n),
                             conj_fecha_cre   = rep(date_created, n),
                             conj_fecha_modif = rep(date_modif, n),
                             rec        = resource.name,
                             rec_des    = resource.desc,
                             rec_fecha  = resource.date,
                             rec_url    = resource.url,
                             rec_format = resource.format,
                             rec_tam    = resource.size,
                             id_conj    = rep(id_conj,n)
                        )
                        )
    }
}
## Write results.
write.csv(all_data,"MAT.csv",row.names = FALSE)
