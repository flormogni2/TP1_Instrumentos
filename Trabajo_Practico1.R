#Trabajo práctico 1. Instrumentos de análisis urbanos

#1. Se creó un repositorio en la cuenta personal de GitHub, con versión de control. 

#2. Se instalaron las librerías

install.packages("tidyverse")
library("tidyverse")

install.packages("sf")
library(sf)

install.packages("dplyr")
library(dplyr)

#3. Se carga la base de datos con la que vamos a trabajar. En este caso, es la base de Mapa de Oportunidades Comerciales de la Ciudad de Buenos Aires. La misma se obtuvo del portal de datos abiertos del Gobierno de la Ciudad. Nuestro objetivo es analizar los principales comercios de la Comuna 1. 

datos_oport_comerciales <- vroom::vroom("https://cdn.buenosaires.gob.ar/datosabiertos/datasets/innovacion-transformacion-digital/mapa-oportunidades-comerciales-moc/zonas.csv")

#Para poder analizar geográficamente los rubros y comercios de incluyó la base de datos que posee las zonas censales y los polígonos. 

zonas <- sf::st_read("https://cdn.buenosaires.gob.ar/datosabiertos/datasets/innovacion-transformacion-digital/mapa-oportunidades-comerciales-moc/zonas-moc.geojson")

#Para poder unir las dos tablas, se modificó el nombre de la columna que tienen en común
datos_oport_comerciales$MOC_ZONAS_ID <- as.character(datos_oport_comerciales$MOC_ZONAS_ID)

datos_oport_comerciales <- datos_oport_comerciales %>% rename(zone_id = MOC_ZONAS_ID)

mapa_oport_comerciales <- left_join(datos_oport_comerciales, zonas, by = "zone_id")
