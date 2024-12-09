rm(list = ls()) # Borro todos los objetos
gc() # Garbage Collection

setwd("/Users/ignacio/MAESTRIA/DMEF/3ra comp")

library(dplyr)
library(readr)

# Obtener la lista de archivos CSV
archivos <- list.files(pattern = "\\.csv$")
if (length(archivos) == 0) {
  stop("No se encontraron archivos CSV en la carpeta.")
}

# Leer y validar los datos
datos <- lapply(archivos, function(archivo) {
  read_csv(archivo, col_types = cols(.default = "c")) %>%
    select(numero_de_cliente, Predicted) %>%
    arrange(numero_de_cliente)
})

# Validar consistencia de clientes
numero_de_cliente <- datos[[1]]$numero_de_cliente
if (!all(sapply(datos, function(df) all(df$numero_de_cliente == numero_de_cliente)))) {
  stop("Los archivos no tienen los mismos clientes o el orden no coincide.")
}

# Aplicar majority voting (al menos 3 votos iguales)
predicciones <- sapply(datos, function(df) as.numeric(df$Predicted))

# Revisar si existen valores no válidos y solucionarlos
predicciones[is.na(predicciones)] <- -1 # Sustituir NA por un valor temporal (-1)

# Calcular la mayoría por fila
majority_votes <- apply(predicciones, 1, function(row) {
  # Crear tabla de frecuencias ignorando el valor temporal (-1)
  freq_table <- table(row[row != -1])
  if (any(freq_table >= 3)) {
    return(as.numeric(names(which.max(freq_table))))
  } else {
    return(NA) # Si no hay mayoría, asignar NA
  }
})

# Crear y guardar los resultados
resultados <- data.frame(
  numero_de_cliente = numero_de_cliente,
  Predicted = majority_votes
)

write_csv(resultados, "predicciones_majority_voting.csv")
message("Resultados guardados en 'predicciones_majority_voting.csv'")
