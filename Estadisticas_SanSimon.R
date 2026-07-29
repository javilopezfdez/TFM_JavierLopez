# ======================================================================
# ANÁLISIS ESTACIONAL DE pCO2, FLUJOS DE CO2 Y SST
# ENSENADA DE SAN SIMÓN
#
# Clasificación:
#   OTO  = SS1, SS2
#   INV  = SS3
#   PRIM = SS4, SS5, SS6, SS7, SS8
#   VER  = SS9
#
# Autor: Javier López Fernández
# ======================================================================


# ======================================================================
# 1. LIMPIAR EL ENTORNO
# ======================================================================

rm(list = ls())
graphics.off()
cat("\014")

options(
  scipen = 999,
  stringsAsFactors = FALSE
)


# ======================================================================
# 2. INSTALAR Y CARGAR PAQUETES
# ======================================================================

paquetes <- c(
  "readxl",
  "dplyr",
  "tidyr",
  "ggplot2",
  "janitor",
  "stringr",
  "rstatix",
  "patchwork",
  "writexl"
)

paquetes_faltantes <- paquetes[
  !vapply(
    paquetes,
    requireNamespace,
    logical(1),
    quietly = TRUE
  )
]

if (length(paquetes_faltantes) > 0) {
  
  install.packages(
    paquetes_faltantes,
    dependencies = TRUE,
    repos = "https://cloud.r-project.org"
  )
}

invisible(
  lapply(
    paquetes,
    library,
    character.only = TRUE
  )
)


# ======================================================================
# 3. RUTA DEL ARCHIVO
# ======================================================================

archivo <- paste0(
  "C:/Users/javil/Desktop/TFM/excel/MUY_AVANZADOS/Agrupar/",
  "SS1_SS9_FLUJOS_BAT_VIENTOS_UNIDOS (version 1) (version 1).xlsb.xlsx"
)

if (!file.exists(archivo)) {
  
  stop(
    paste0(
      "\nNo se encuentra el archivo:\n\n",
      archivo,
      "\n\nComprueba que el nombre y la ruta sean correctos."
    )
  )
}


# ======================================================================
# 4. CARPETA PARA GUARDAR LOS RESULTADOS
# ======================================================================

carpeta_salida <- file.path(
  dirname(archivo),
  "RESULTADOS_R_ARTICULO"
)

if (!dir.exists(carpeta_salida)) {
  
  dir.create(
    carpeta_salida,
    recursive = TRUE
  )
}

cat(
  "\nLos resultados se guardarán en:\n",
  carpeta_salida,
  "\n"
)


# ======================================================================
# 5. LEER EL ARCHIVO EXCEL
# ======================================================================

hojas <- excel_sheets(archivo)

cat("\nHojas disponibles en el Excel:\n")
print(hojas)

# Se utiliza la primera hoja
datos_originales <- read_excel(
  path = archivo,
  sheet = hojas[1],
  guess_max = 200000
)

# Limpiar los nombres de las columnas
datos_originales <- datos_originales %>%
  clean_names()

cat("\nDimensiones del archivo:\n")

cat(
  nrow(datos_originales),
  "filas y",
  ncol(datos_originales),
  "columnas\n"
)

cat("\nColumnas disponibles:\n")
print(names(datos_originales))


# ======================================================================
# 6. FUNCIÓN PARA ENCONTRAR AUTOMÁTICAMENTE LAS COLUMNAS
# ======================================================================

buscar_columna <- function(
    nombres,
    candidatos,
    patrones = NULL,
    obligatoria = TRUE,
    nombre_variable = "variable") {
  
  # Buscar coincidencias exactas
  coincidencias_exactas <- candidatos[
    candidatos %in% nombres
  ]
  
  if (length(coincidencias_exactas) > 0) {
    
    return(coincidencias_exactas[1])
  }
  
  # Buscar mediante patrones
  if (!is.null(patrones)) {
    
    for (patron in patrones) {
      
      coincidencias <- grep(
        pattern = patron,
        x = nombres,
        ignore.case = TRUE,
        value = TRUE
      )
      
      if (length(coincidencias) > 0) {
        
        return(coincidencias[1])
      }
    }
  }
  
  if (obligatoria) {
    
    stop(
      paste0(
        "\nNo se encontró la columna correspondiente a ",
        nombre_variable,
        ".\n\nColumnas disponibles:\n",
        paste(nombres, collapse = ", ")
      )
    )
  }
  
  return(NA_character_)
}


nombres <- names(datos_originales)


# ======================================================================
# 7. IDENTIFICAR LAS COLUMNAS IMPORTANTES
# ======================================================================

col_campana <- "ID"
  
  patrones = c(
    "^camp",
    "^salida",
    "cruise",
    "campaign"
  ),
  
  nombre_variable = "campaña o salida"
)


col_pco2 <- buscar_columna(
  nombres = nombres,
  
  candidatos = c(
    "pco2",
    "p_co2",
    "pco2_ajustada",
    "p_co2_ajustada",
    "pco2_corr",
    "p_co2_corr",
    "pco2_corregida",
    "p_co2_corregida"
  ),
  
  patrones = c(
    "^pco2$",
    "^p_co2$",
    "^pco2_ajustada$",
    "^pco2_corr"
  ),
  
  nombre_variable = "pCO2"
)


col_fco2 <- buscar_columna(
  nombres = nombres,
  
  candidatos = c(
    "fco2_mol_cm2yr",
    "fco2_mol_c_m2yr",
    "fco2_mol_c_m2_yr",
    "fco2_mol_cm2_yr",
    "fco2_mol_cm2ano",
    "fco2_mol_c_m2_ano",
    "fco2",
    "f_co2"
  ),
  
  patrones = c(
    "^fco2.*mol.*m2.*yr",
    "^f_co2.*mol.*m2.*yr",
    "^fco2.*mol.*m2.*ano",
    "^fco2$",
    "^f_co2$"
  ),
  
  nombre_variable = "flujo de CO2"
)


col_sst <- buscar_columna(
  nombres = nombres,
  
  candidatos = c(
    "sst",
    "temperatura",
    "temperature",
    "temp",
    "temperatura_superficial"
  ),
  
  patrones = c(
    "^sst$",
    "^temperatura$",
    "^temperature$",
    "sea_surface_temperature"
  ),
  
  nombre_variable = "SST"
)


# Columnas opcionales
col_salinidad <- buscar_columna(
  nombres = nombres,
  
  candidatos = c(
    "sss",
    "sal",
    "salinidad",
    "salinity"
  ),
  
  patrones = c(
    "^sss$",
    "^sal$",
    "salinidad",
    "salinity"
  ),
  
  obligatoria = FALSE,
  nombre_variable = "salinidad"
)


col_oxigeno <- buscar_columna(
  nombres = nombres,
  
  candidatos = c(
    "sso",
    "o2",
    "oxygen",
    "oxigeno",
    "oxigeno_disuelto"
  ),
  
  patrones = c(
    "^sso$",
    "^o2$",
    "oxygen",
    "oxigeno"
  ),
  
  obligatoria = FALSE,
  nombre_variable = "oxígeno"
)


cat("\nColumnas identificadas:\n")
cat("Campaña:", col_campana, "\n")
cat("pCO2:", col_pco2, "\n")
cat("Flujo de CO2:", col_fco2, "\n")
cat("SST:", col_sst, "\n")
cat("Salinidad:", col_salinidad, "\n")
cat("Oxígeno:", col_oxigeno, "\n")


# ======================================================================
# 8. FUNCIÓN PARA CONVERTIR COLUMNAS A NUMÉRICO
# ======================================================================

convertir_numerico <- function(x) {
  
  if (is.numeric(x)) {
    
    return(as.numeric(x))
  }
  
  x <- as.character(x)
  x <- trimws(x)
  x <- gsub(" ", "", x)
  
  # Convertir coma decimal en punto
  x <- gsub(
    pattern = ",",
    replacement = ".",
    x = x,
    fixed = TRUE
  )
  
  suppressWarnings(
    as.numeric(x)
  )
}


# ======================================================================
# 9. EXTRAER EL CÓDIGO DE CAMPAÑA
# ======================================================================

# ======================================================================
# IDENTIFICAR LA CAMPAÑA A PARTIR DE LA COLUMNA ID
# ======================================================================

col_campana <- "id"

if (!col_campana %in% names(datos_originales)) {
  stop(
    paste0(
      "No se encuentra la columna 'id'.\n",
      "Columnas disponibles: ",
      paste(names(datos_originales), collapse = ", ")
    )
  )
}

# Convertir ID a número de campaña
numero_campana <- suppressWarnings(
  as.integer(
    as.character(datos_originales[[col_campana]])
  )
)

# Crear códigos SS1, SS2, ..., SS9
campana <- ifelse(
  !is.na(numero_campana),
  paste0("SS", numero_campana),
  NA_character_
)

cat("\nCampañas detectadas:\n")
print(sort(unique(campana)))


# ======================================================================
# 10. ASIGNAR LAS ESTACIONES DEL AÑO
# ======================================================================

# CLASIFICACIÓN CORREGIDA:
#
# OTO  = SS1 y SS2
# INV  = SS3
# PRIM = SS4, SS5, SS6, SS7 y SS8
# VER  = SS9

mapa_estaciones <- c(
  "SS1" = "OTO",
  "SS2" = "OTO",
  "SS3" = "INV",
  "SS4" = "PRIM",
  "SS5" = "PRIM",
  "SS6" = "PRIM",
  "SS7" = "PRIM",
  "SS8" = "PRIM",
  "SS9" = "VER"
)

estacion <- unname(
  mapa_estaciones[campana]
)

# Comprobar si hay campañas no clasificadas
campanas_sin_clasificar <- unique(
  campana[
    !is.na(campana) &
      is.na(estacion)
  ]
)

if (length(campanas_sin_clasificar) > 0) {
  
  warning(
    paste0(
      "\nHay campañas sin clasificar:\n",
      paste(
        campanas_sin_clasificar,
        collapse = ", "
      )
    )
  )
}


# ======================================================================
# 11. CREAR LA TABLA DE ANÁLISIS
# ======================================================================

datos <- datos_originales

datos$campana <- campana

datos$estacion <- factor(
  estacion,
  levels = c(
    "INV",
    "PRIM",
    "VER",
    "OTO"
  ),
  ordered = TRUE
)

datos$pco2 <- convertir_numerico(
  datos_originales[[col_pco2]]
)

datos$fco2 <- convertir_numerico(
  datos_originales[[col_fco2]]
)

datos$sst <- convertir_numerico(
  datos_originales[[col_sst]]
)


# Añadir salinidad con nombre normalizado
if (!is.na(col_salinidad)) {
  
  datos$salinidad <- convertir_numerico(
    datos_originales[[col_salinidad]]
  )
}


# Añadir oxígeno con nombre normalizado
if (!is.na(col_oxigeno)) {
  
  datos$oxigeno <- convertir_numerico(
    datos_originales[[col_oxigeno]]
  )
}


# Eliminar filas sin campaña o sin estación
datos <- datos %>%
  filter(
    !is.na(campana),
    !is.na(estacion)
  )


# ======================================================================
# 12. COMPROBAR LA CLASIFICACIÓN
# ======================================================================

conteo_campanas <- datos %>%
  count(
    estacion,
    campana,
    name = "n_observaciones"
  ) %>%
  arrange(
    estacion,
    campana
  )

cat("\nNúmero de observaciones por campaña y estación:\n")
print(conteo_campanas)


numero_campanas_estacion <- datos %>%
  distinct(
    estacion,
    campana
  ) %>%
  count(
    estacion,
    name = "n_campanas"
  )

cat("\nNúmero de campañas independientes por estación:\n")
print(numero_campanas_estacion)


# ======================================================================
# 13. NORMALIZAR pCO2 A UNA TEMPERATURA COMÚN
# ======================================================================

temperatura_referencia <- mean(
  datos$sst,
  na.rm = TRUE
)

if (is.finite(temperatura_referencia)) {
  
  datos <- datos %>%
    mutate(
      pco2_tref = pco2 *
        exp(
          0.0423 *
            (
              temperatura_referencia -
                sst
            )
        )
    )
  
} else {
  
  datos$pco2_tref <- NA_real_
}

cat(
  "\nTemperatura de referencia utilizada:",
  round(temperatura_referencia, 2),
  "°C\n"
)


# ======================================================================
# 14. FUNCIONES PARA ESTADÍSTICAS SEGURAS
# ======================================================================

media_segura <- function(x) {
  
  if (all(is.na(x))) {
    
    return(NA_real_)
  }
  
  mean(
    x,
    na.rm = TRUE
  )
}


sd_segura <- function(x) {
  
  if (sum(!is.na(x)) < 2) {
    
    return(NA_real_)
  }
  
  sd(
    x,
    na.rm = TRUE
  )
}


mediana_segura <- function(x) {
  
  if (all(is.na(x))) {
    
    return(NA_real_)
  }
  
  median(
    x,
    na.rm = TRUE
  )
}


cuantil_seguro <- function(x, probabilidad) {
  
  if (all(is.na(x))) {
    
    return(NA_real_)
  }
  
  as.numeric(
    quantile(
      x,
      probs = probabilidad,
      na.rm = TRUE
    )
  )
}


minimo_seguro <- function(x) {
  
  if (all(is.na(x))) {
    
    return(NA_real_)
  }
  
  min(
    x,
    na.rm = TRUE
  )
}


maximo_seguro <- function(x) {
  
  if (all(is.na(x))) {
    
    return(NA_real_)
  }
  
  max(
    x,
    na.rm = TRUE
  )
}


# ======================================================================
# 15. RESUMEN ESTADÍSTICO POR ESTACIÓN
# ======================================================================

datos_largos <- datos %>%
  select(
    campana,
    estacion,
    pco2,
    pco2_tref,
    fco2,
    sst
  ) %>%
  pivot_longer(
    cols = c(
      pco2,
      pco2_tref,
      fco2,
      sst
    ),
    names_to = "variable",
    values_to = "valor"
  )


resumen_estacional <- datos_largos %>%
  group_by(
    estacion,
    variable
  ) %>%
  summarise(
    n_observaciones = sum(
      !is.na(valor)
    ),
    
    n_campanas = n_distinct(
      campana[!is.na(valor)]
    ),
    
    media = media_segura(valor),
    
    desviacion_estandar = sd_segura(valor),
    
    mediana = mediana_segura(valor),
    
    q1 = cuantil_seguro(
      valor,
      0.25
    ),
    
    q3 = cuantil_seguro(
      valor,
      0.75
    ),
    
    rango_intercuartil = q3 - q1,
    
    minimo = minimo_seguro(valor),
    
    maximo = maximo_seguro(valor),
    
    .groups = "drop"
  )


cat("\nResumen estadístico por estación:\n")
print(resumen_estacional)


# ======================================================================
# 16. MEDIANAS POR CAMPAÑA
# ======================================================================

datos_campana <- datos %>%
  group_by(
    estacion,
    campana
  ) %>%
  summarise(
    n = n(),
    
    pco2 = mediana_segura(pco2),
    
    pco2_tref = mediana_segura(
      pco2_tref
    ),
    
    fco2 = mediana_segura(fco2),
    
    sst = mediana_segura(sst),
    
    .groups = "drop"
  )


cat("\nMedianas por campaña:\n")
print(datos_campana)


# ======================================================================
# 17. FUNCIÓN PARA KRUSKAL-WALLIS Y DUNN
# ======================================================================

analisis_no_parametrico <- function(
    tabla,
    variable,
    nombre_variable) {
  
  tabla_prueba <- tabla %>%
    transmute(
      estacion = droplevels(estacion),
      valor = .data[[variable]]
    ) %>%
    filter(
      !is.na(estacion),
      !is.na(valor)
    )
  
  if (n_distinct(tabla_prueba$estacion) < 2) {
    
    return(
      list(
        kruskal = tibble(
          variable = nombre_variable,
          error = "No hay suficientes grupos"
        ),
        
        efecto = tibble(
          variable = nombre_variable,
          error = "No hay suficientes grupos"
        ),
        
        dunn = tibble(
          variable = nombre_variable,
          error = "No hay suficientes grupos"
        )
      )
    )
  }
  
  resultado_kw <- tryCatch(
    
    tabla_prueba %>%
      kruskal_test(
        valor ~ estacion
      ) %>%
      mutate(
        variable = nombre_variable,
        .before = 1
      ),
    
    error = function(e) {
      
      tibble(
        variable = nombre_variable,
        error = conditionMessage(e)
      )
    }
  )
  
  
  resultado_efecto <- tryCatch(
    
    tabla_prueba %>%
      kruskal_effsize(
        valor ~ estacion
      ) %>%
      mutate(
        variable = nombre_variable,
        .before = 1
      ),
    
    error = function(e) {
      
      tibble(
        variable = nombre_variable,
        error = conditionMessage(e)
      )
    }
  )
  
  
  resultado_dunn <- tryCatch(
    
    tabla_prueba %>%
      dunn_test(
        valor ~ estacion,
        p.adjust.method = "holm"
      ) %>%
      mutate(
        variable = nombre_variable,
        .before = 1
      ),
    
    error = function(e) {
      
      tibble(
        variable = nombre_variable,
        error = conditionMessage(e)
      )
    }
  )
  
  
  return(
    list(
      kruskal = resultado_kw,
      efecto = resultado_efecto,
      dunn = resultado_dunn
    )
  )
}


# ======================================================================
# 18. PRUEBAS ESTADÍSTICAS EXPLORATORIAS
#
# IMPORTANTE:
# Se realizan con todos los registros continuos, por lo que deben
# interpretarse como análisis exploratorios debido a la autocorrelación
# temporal y espacial dentro de cada campaña.
# ======================================================================

resultado_pco2 <- analisis_no_parametrico(
  tabla = datos,
  variable = "pco2",
  nombre_variable = "pCO2"
)

resultado_pco2_tref <- analisis_no_parametrico(
  tabla = datos,
  variable = "pco2_tref",
  nombre_variable = "pCO2 normalizada"
)

resultado_fco2 <- analisis_no_parametrico(
  tabla = datos,
  variable = "fco2",
  nombre_variable = "Flujo de CO2"
)

resultado_sst <- analisis_no_parametrico(
  tabla = datos,
  variable = "sst",
  nombre_variable = "SST"
)


resultados_kruskal <- bind_rows(
  resultado_pco2$kruskal,
  resultado_pco2_tref$kruskal,
  resultado_fco2$kruskal,
  resultado_sst$kruskal
)

resultados_efecto <- bind_rows(
  resultado_pco2$efecto,
  resultado_pco2_tref$efecto,
  resultado_fco2$efecto,
  resultado_sst$efecto
)

resultados_dunn <- bind_rows(
  resultado_pco2$dunn,
  resultado_pco2_tref$dunn,
  resultado_fco2$dunn,
  resultado_sst$dunn
)


cat("\n====================================================\n")
cat("RESULTADOS DE KRUSKAL-WALLIS\n")
cat("====================================================\n")
print(resultados_kruskal)

cat("\n====================================================\n")
cat("TAMAÑOS DEL EFECTO\n")
cat("====================================================\n")
print(resultados_efecto)

cat("\n====================================================\n")
cat("COMPARACIONES POST HOC DE DUNN\n")
cat("====================================================\n")
print(resultados_dunn)


# ======================================================================
# 19. FUNCIÓN PARA CREAR BOXPLOTS
# ======================================================================

crear_boxplot <- function(
    tabla,
    tabla_campana,
    variable,
    titulo,
    etiqueta_y) {
  
  ggplot(
    tabla,
    aes(
      x = estacion,
      y = .data[[variable]]
    )
  ) +
    
    # Mediciones individuales
    geom_jitter(
      width = 0.12,
      height = 0,
      size = 0.7,
      alpha = 0.10
    ) +
    
    # Boxplot
    geom_boxplot(
      width = 0.55,
      fill = "#1286C4",
      colour = "black",
      linewidth = 0.75,
      outlier.shape = NA
    ) +
    
    # Mediana de cada campaña
    geom_point(
      data = tabla_campana,
      aes(
        x = estacion,
        y = .data[[variable]]
      ),
      inherit.aes = FALSE,
      shape = 23,
      size = 3,
      stroke = 0.9,
      fill = "white",
      colour = "black"
    ) +
    
    labs(
      title = titulo,
      x = "Estación del año",
      y = etiqueta_y,
      caption = "Los rombos representan la mediana de cada campaña"
    ) +
    
    scale_x_discrete(
      drop = FALSE,
      labels = c(
        "INV" = "INV",
        "PRIM" = "PRIM",
        "VER" = "VER",
        "OTO" = "OTO"
      )
    ) +
    
    theme_bw(
      base_size = 12
    ) +
    
    theme(
      plot.title = element_text(
        hjust = 0.5,
        face = "bold",
        size = 14
      ),
      
      axis.title = element_text(
        face = "bold"
      ),
      
      axis.text = element_text(
        colour = "black"
      ),
      
      panel.grid.minor = element_blank(),
      
      panel.grid.major = element_line(
        colour = "grey85",
        linewidth = 0.4
      ),
      
      plot.caption = element_text(
        hjust = 0,
        size = 8,
        colour = "grey30"
      )
    )
}


# ======================================================================
# 20. CREAR LOS GRÁFICOS
# ======================================================================

grafico_fco2 <- crear_boxplot(
  tabla = datos,
  tabla_campana = datos_campana,
  variable = "fco2",
  titulo = expression(
    "Flujo océano-atmósfera de CO"[2]
  ),
  etiqueta_y = expression(
    F[CO[2]]~(mol~C~m^{-2}~año^{-1})
  )
)


grafico_pco2 <- crear_boxplot(
  tabla = datos,
  tabla_campana = datos_campana,
  variable = "pco2",
  titulo = expression(
    "pCO"[2]~"superficial"
  ),
  etiqueta_y = expression(
    pCO[2]~(mu*atm)
  )
)


grafico_sst <- crear_boxplot(
  tabla = datos,
  tabla_campana = datos_campana,
  variable = "sst",
  titulo = "Temperatura superficial",
  etiqueta_y = expression(
    SST~(degree*C)
  )
)


grafico_pco2_normalizada <- crear_boxplot(
  tabla = datos,
  tabla_campana = datos_campana,
  variable = "pco2_tref",
  titulo = expression(
    "pCO"[2]~"normalizada por temperatura"
  ),
  etiqueta_y = expression(
    pCO[2]~(mu*atm)
  )
)


# Mostrar los gráficos
print(grafico_fco2)
print(grafico_pco2)
print(grafico_sst)
print(grafico_pco2_normalizada)


# ======================================================================
# 21. FIGURA COMBINADA
# ======================================================================

figura_combinada <- (
  grafico_fco2 |
    grafico_pco2
) / (
  grafico_sst |
    grafico_pco2_normalizada
) +
  plot_annotation(
    tag_levels = "A"
  )

print(figura_combinada)


# ======================================================================
# 22. GUARDAR LOS GRÁFICOS
# ======================================================================

ggsave(
  filename = file.path(
    carpeta_salida,
    "boxplot_flujo_CO2.png"
  ),
  plot = grafico_fco2,
  width = 16,
  height = 13,
  units = "cm",
  dpi = 600,
  bg = "white"
)


ggsave(
  filename = file.path(
    carpeta_salida,
    "boxplot_pCO2.png"
  ),
  plot = grafico_pco2,
  width = 16,
  height = 13,
  units = "cm",
  dpi = 600,
  bg = "white"
)


ggsave(
  filename = file.path(
    carpeta_salida,
    "boxplot_SST.png"
  ),
  plot = grafico_sst,
  width = 16,
  height = 13,
  units = "cm",
  dpi = 600,
  bg = "white"
)


ggsave(
  filename = file.path(
    carpeta_salida,
    "boxplot_pCO2_normalizada.png"
  ),
  plot = grafico_pco2_normalizada,
  width = 16,
  height = 13,
  units = "cm",
  dpi = 600,
  bg = "white"
)


ggsave(
  filename = file.path(
    carpeta_salida,
    "figura_estacional_combinada.png"
  ),
  plot = figura_combinada,
  width = 24,
  height = 19,
  units = "cm",
  dpi = 600,
  bg = "white"
)


ggsave(
  filename = file.path(
    carpeta_salida,
    "figura_estacional_combinada.pdf"
  ),
  plot = figura_combinada,
  width = 24,
  height = 19,
  units = "cm",
  device = cairo_pdf
)


# ======================================================================
# 23. GUARDAR LAS TABLAS EN EXCEL
# ======================================================================

archivo_resultados <- file.path(
  carpeta_salida,
  "resultados_estacionales_R.xlsx"
)

write_xlsx(
  list(
    conteo_campanas = conteo_campanas,
    campanas_por_estacion = numero_campanas_estacion,
    resumen_estacional = resumen_estacional,
    medianas_por_campana = datos_campana,
    kruskal_wallis = resultados_kruskal,
    tamanos_efecto = resultados_efecto,
    posthoc_dunn = resultados_dunn
  ),
  path = archivo_resultados
)


# Guardar también los datos preparados
archivo_datos_preparados <- file.path(
  carpeta_salida,
  "datos_preparados_R.xlsx"
)

write_xlsx(
  datos,
  path = archivo_datos_preparados
)


# ======================================================================
# 24. MENSAJE FINAL
# ======================================================================

cat("\n====================================================\n")
cat("ANÁLISIS TERMINADO CORRECTAMENTE\n")
cat("====================================================\n")

cat(
  "\nClasificación utilizada:\n",
  "OTO  = SS1 y SS2\n",
  "INV  = SS3\n",
  "PRIM = SS4, SS5, SS6, SS7 y SS8\n",
  "VER  = SS9\n"
)

cat(
  "\nResultados guardados en:\n",
  carpeta_salida,
  "\n"
)

cat(
  "\nArchivo de resultados:\n",
  archivo_resultados,
  "\n"
)

