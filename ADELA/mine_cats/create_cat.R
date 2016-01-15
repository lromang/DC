#! /usr/bin/Rscript

## Librerías utilizadas
library(stringr)
library(plyr)
library(RCurl)
library(RJSONIO)
## Lectura de datos

cat_data <- readLines("cat_inst.txt")

## Estructurar datos
## Obtenemos nombres de institución
titles <- cat_data[str_detect(cat_data,"title:")]
titles <- laply(titles, function(t)t <- str_split(t,": ")[[1]][2])
## Obtenemos url de catálogos
urls   <- cat_data[str_detect(cat_data,"url:")]
urls   <- laply(urls, function(t)t <- paste0("http://adela.datos.gob.mx/",str_split(t,": ")[[1]][2],"/catalogo.json"))
## Obtenemos fechas de edición
issued   <- laply(urls, function(t)t <- fromJSON(getURL(t))$issued)
modified <- laply(urls, function(t)t <- fromJSON(getURL(t))$modified)

## Catalog data
data <- data.frame(
    dep = titles,
    url = urls,
    created = issued,
    modified = modified
)
write.csv(data,"data_catalogs.csv",row.names = FALSE)
