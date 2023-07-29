#Trabajo práctico 1. Instrumentos de análisis urbanos

#1. Se creó un repositorio en la cuenta personal de GitHub, con versión de control. 

#2. Se instalaron las librerías

install.packages("tidyverse")
library(tidyverse)

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

# Para ver los datos: 
skimr::skim(mapa_oport_comerciales)

unique(mapa_oport_comerciales$RUBRO_PREDOMINANTE)

#Selecciono las columnas que quiero analizar
mapa_oc_red <- mapa_oport_comerciales %>% 
  select(zone_id, PRECIO_PROMEDIO_ALQUILER_LOCAL, RUBRO_PREDOMINANTE, CANTIDAD_HOGARES, POBLACION_VIVIENTE, POBLACION_TRABAJADORA, SUPERFICIE_M2_PROMEDIO_ALQUILER, radios, geometry)

colnames(mapa_oc_red)

#Convierto la columna superficie a numeric en vez de character

class(mapa_oc_red$SUPERFICIE_M2_PROMEDIO_ALQUILER)
mapa_oc_red$superficie_m2_promedio <- as.numeric(mapa_oc_red$SUPERFICIE_M2_PROMEDIO_ALQUILER)

class(mapa_oc_red$CANTIDAD_HOGARES)

mapa_oc_red <- mapa_oc_red %>% 
  mutate(across(.cols = where(is.numeric), 
                ~ round(x = ., digits = 1)))

mean(mapa_oc_red$CANTIDAD_HOGARES)

skimr::skim(mapa_oc_red)

# Queremos analizar los principales rubros de acuerdo con la cantidad media de las familias. 

Resumen_rubros <- mapa_oc_red %>%
  select(-geometry) %>%
  group_by(RUBRO_PREDOMINANTE) %>%
  summarise(promedio_hogares = mean(CANTIDAD_HOGARES)) %>%
  arrange(desc(promedio_hogares))

print(Resumen_rubros)

##Resulta llamativo que el primer rubro predominante en base al promedio de hogares sea "Salud y Cosmética", mientras que la categoría "Supermercados y almacenes" se encuentra en el quinto puesto, luego de "Kioscos y loterias", "Indumentaria" y "óptica y joyería", que parecerían rubros menos relevantes en el día a día. 
