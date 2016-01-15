#! /usr/bin/Rscript

## Luis Manuel Román García
## Rutinas para minar el contenido de
## http://busca.datos.gob.mx/#/conjuntos
##-----------------------------
## Librerias utilizadas
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
##-----------------------------
source("get_plans.R")

get.edit.inv <- function(url){
    ## Obtiene la informacion de la ultima modificacion al inventario de datos
    ## de cada institucion.
    ## IN
    ## url: la direccion de la pagina de donde se quiere obtener la informacion
    ## OUT
    ## data.frame con la informacion de la ultima modificacion al inventario
    ## de datos de cada institucion.
    inst      <- str_split(url,"/")[[1]][5]
    url_cat   <- get.links.inv(url)[1]
    if(!is.na(url_cat)){
        page      <- getURL(url)
        tree      <- htmlParse(page)
        values    <- xpathApply(tree,
                                path = "//table[@class='expanded-table inventories-list']//td",
                                fun  = xmlValue)
        values    <- unlist(values)
        last.mod  <- data.frame(inst      = inst,
                                url       = url,
                                url_cat   = url_cat,
                                fecha     = to.date(values[3],values[4]),
                                conjuntos = values[5],
                                recursos  = values[6])
    }else{
        last.mod  <- data.frame(inst      = inst,
                                url       = url,
                                url_cat   = NA,
                                fecha     = NA,
                                conjuntos = NA,
                                recursos  = NA)
    }
    last.mod
}


## Instrucción API
## ---------------------------------------
## http://catalogo.datos.gob.mx/api/3/action/
## ---------------------------------------
## Valores recientes
## recently_changed_packages_activity_list
## ---------------------------------------
## Todos los paquetes
## package_list
## ---------------------------------------
## Todos los paquetes todos los recursos
## current_package_list_with_resources
## ---------------------------------------
## Búsqueda personalizada
## resource_search?query=name:District%20Names
## ---------------------------------------
## ---------------------------------------
## ---------------------------------------
## Lectura de datos
## ---------------------------------------
## ---------------------------------------
## ---------------------------------------

#########################################
#########################################
## get_recent_data
#########################################
## Obtiene los datos referenetes a las
## últimas actualizaciones en ckan.
#########################################
get_recent_data <- function(){
    ## Generamos la url de la búsqueda.
    base_url <- "http://catalogo.datos.gob.mx/api/3/action/"
    activity <- "recently_changed_packages_activity_list"
    ## Descargamos en formato JSON.
    recent_act <- fromJSON(getURL(paste0(base_url,activity)))
    ## Almacenamos los resultados en un formato
    ## tipo tabla.
    results <- recent_act$result
    package   <- laply(results,function(t)t <- t$data$package$name)
    modified  <- laply(results,function(t)t <- t$data$package$metadata_modified)
    url       <- laply(results,function(t)t <-
                                            {if(length(t$data$package$url) > 0){t$data$package$url}else{NA}})
    data.frame(title = package, date = modified, url = url)
}


#########################################
#########################################
## get_all_data
#########################################
## Obtiene los datos referenetes a todos
## los conjuntos y todos sus recursos.
#########################################
get_all_data <- function(){
    ## Generamos la url de la búsqueda.
    base_url <- "http://catalogo.datos.gob.mx/api/3/action/"
    activity <- "current_package_list_with_resources"
    ## Descargamos en formato JSON.
    recent_act <- getURL(paste0(base_url,activity))
    recent_act_json <- RJSONIO::fromJSON(recent_act)
    ## Almacenamos los resultados en un formato
    ## tipo tabla.
    results <- recent_act$result
    package   <- laply(results,function(t)t <- t$data$package$name)
    modified  <- laply(results,function(t)t <- t$data$package$metadata_modified)
    url       <- laply(results,function(t)t <-
                                            {if(length(t$data$package$url) > 0){t$data$package$url}else{NA}})
    data.frame(title = package, date = modified, url = url)
}


#########################################
#########################################
## process_all_data
#########################################
## Obtiene los datos referenetes a todos
## los conjuntos y todos sus recursos.
#########################################
process_all_data <- function(){
    file <- str_trim(readLines("set_data.txt"))
    ## Institución
    inst <- file[str_detect(file,"Inst:")] %>%
        str_replace("Inst: ","")
    ## Conjunto
    dataset <- file[str_detect(file,"Dataset:")] %>%
        str_replace("Dataset: ","")
    ## Descripción
    desc <- file[str_detect(file,"Desc:")] %>%
        str_replace("Desc: ","")
    ## Fecha
    date <- file[str_detect(file,"Published:")] %>%
        str_replace("Published: ","")
    ## Recursos
    rec <- file[str_detect(file,"resources:")] %>%
        str_replace("resources: ","")

    ## Juntar resultados.
    data.frame(Inst = inst, Conjunto = dataset, Recursos = rec,  Desc = desc, fecha = date)
}

#####
## Obtención datos
#####
data <- process_all_data()

write.csv(data,
          paste0("info_datos_gob-",
                       today(),
                      ".csv"),
          row.names = FALSE)

#####
## statistics
#####
data$Recursos <- extract_numeric(data$Recursos)
data_table    <- data.table(data)
conjuntos     <- nrow(data_table)
print("###################################################")
print(paste0( "Conjuntos: ",conjuntos ))
recursos      <- data_table[,sum(Recursos)]
print(paste0( "Recursos: ", recursos ))
print("###################################################")
#####
data_table    <- filter(data_table, Inst != "null")
top_conjuntos <- data_table[,.N, by = Inst]
top_conjuntos <- top_conjuntos[order(top_conjuntos$N,
                                    decreasing = TRUE),
                              ]
print("###################################################")
print("10 instituciones con más conjuntos")
print(head(top_conjuntos,10))
top_recursos <- data_table[,sum(Recursos), by = Inst]
top_recursos <- top_recursos[order(top_recursos$V1,
                                    decreasing = TRUE),
                            ]
print("10 instituciones con más recursos")
print(head(top_recursos,10))
print("###################################################")
all_plans <- filter(all_plans, dep != "adela-mxabierto")
print(paste0("Planse de apertura: ", length(unique(all_plans$dep))))

###
## Time line
###
## Graphs!!!!
######################################
## Institutions
######################################
##data <- read.csv("info_datos_gob-2015-11-03.csv", stringsAsFactors = FALSE)
graph_data       <- data.table(data[,c(1,2,3,5)])
graph_data$fecha <- as.Date(graph_data$fecha)
#####################################
################base#################
base_inst <- length(unique(graph_data[graph_data$fecha   <= '2015-07-15']$Inst))
base_set  <- sum(plyr::count(graph_data[graph_data$fecha <= '2015-07-15']$Conjunto)$freq)
base_rec  <- sum(extract_numeric(graph_data[graph_data$fecha             <= '2015-07-15']$Recursos))
#####################################
#####################################
graph_data <- dplyr::filter(graph_data, fecha > '2015-07-15')
inst_data  <- graph_data[,min(fecha), by = "Inst"]
inst_data_count <- inst_data[,.N, by = "V1"]
## Graph
png(paste0("../graphs/inst_",today(),".png"), width=1200)
ggplot(data = inst_data_count,
       aes(x = V1, y = N)) + geom_area(col  = "#78A300",
                                       fill = "#78A300",
                                       alpha = .08) +
    theme(
        panel.background = element_rect(fill = "white"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color = "#EEEEEE"),
        axis.title = element_blank(),
        axis.text.y = element_text(color = "#78A300"),
        axis.text.x = element_text(color = "#9E9E9E"))
dev.off()
## Graph acumulada
inst_data_count[1,]$N <- inst_data_count[1,]$N + base_inst
png(paste0("../graphs/inst_cum_",today(),".png"), width=1200)
ggplot(data = inst_data_count,
       aes(x = sort(V1), y = cumsum(N))) + geom_area(col  = "#78A300",
                                       fill = "#78A300",
                                       alpha = .08) +
    theme(
        panel.background = element_rect(fill = "white"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color = "#EEEEEE"),
        axis.title = element_blank(),
        axis.text.y = element_text(color = "#78A300"),
        axis.text.x = element_text(color = "#9E9E9E"))
dev.off()
######################################
#### Recursos y Conjuntos
######################################
## Recursos
rec_data <- graph_data[,sum(Recursos), by = fecha]
rec_data$class <- "Recurso"

## Conjuntos
set_data <- graph_data[,min(fecha), by = Conjunto]
set_data_count <- set_data[,.N, by = "V1"]
set_data_count$class <- "Conjunto"
names(set_data_count) <- c("fecha", "V1", "class")

## All data
rec_set_data <- rbind(rec_data, set_data_count)
## Graph
png(paste0("../graphs/set_rec_",today(),".png"), width=1200)
ggplot(data = rec_set_data,
       aes(x = fecha, y = V1, col = class, fill = class )) +
    geom_area(alpha = .08) + facet_wrap(~class, scales = "free") +
    theme(
        panel.background = element_rect(fill = "white"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color = "#EEEEEE"),
        axis.title = element_blank(),
        axis.text.y = element_text(color = "#78A300"),
        axis.text.x = element_text(color = "#9E9E9E"),
        legend.position = "none",#c(.55, .85),
        legend.background = element_rect(colour = "#9E9E9E")
    ) +
    scale_colour_manual(labels = c("Conjuntos", "Recursos"),
                        values = c("#78A300","#03A9F4")) +
    scale_fill_manual(labels = c("Conjuntos", "Recursos"),
                      values = c("#78A300","#03A9F4"))
dev.off()
## Graph acumulada
rec_data[1,]$V1 <- rec_data[1,]$V1 + base_rec
set_data_count[1,]$V1 <- set_data_count[1,]$V1 + base_set
rec_set_data <- rbind(rec_data, set_data_count)
cum_rec_set <- rec_set_data[,list(sort(fecha), cumsum(V1)), by = class]
png(paste0("../graphs/set_rec_cum_",today(),".png"), width=1000)
ggplot(data = cum_rec_set,
       aes(x = V1, y = V2, col = class, fill = class )) +
    geom_area(alpha = .08) + facet_wrap(~class, scales = "free") +
    theme(
        panel.background = element_rect(fill = "white"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color = "#EEEEEE"),
        axis.title = element_blank(),
        axis.text.y = element_text(color = "#78A300"),
        axis.text.x = element_text(color = "#9E9E9E"),
        legend.position = "none",#c(.55, .85),
        legend.background = element_rect(colour = "#9E9E9E")
    ) +
    scale_colour_manual(labels = c("Conjuntos", "Recursos"),
                        values = c("#78A300","#03A9F4")) +
    scale_fill_manual(labels = c("Conjuntos", "Recursos"),
                      values = c("#78A300","#03A9F4"))
dev.off()
