# -*- coding: utf-8 -*-
"""
Created on Wed May 20 13:32:48 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación:
"""

import xarray as xr
import pandas as pd
import numpy as np
from pathlib import Path

# Carpeta con los 24 NetCDF
carpeta_nc = Path(r"C:\Users\javil\Desktop\TFM\nc\12mayo")

# Archivo Excel de salida
archivo_salida = Path(r"C:\Users\javil\Desktop\TFM\excel\SS7_cop.xlsx")

archivos = sorted(carpeta_nc.glob("*.nc"))

# Coordenada objetivo
lat_obj = 42.306362
lon_obj = -8.643942

vientos = []

for archivo in archivos:
    ds = xr.open_dataset(archivo)

    # Detectar nombres de coordenadas
    lat_name = "latitude" if "latitude" in ds.coords else "lat"
    lon_name = "longitude" if "longitude" in ds.coords else "lon"

    # Ajustar longitud si el NetCDF usa 0-360 en vez de -180 a 180
    lon_nc = ds[lon_name]
    if lon_nc.max() > 180:
        lon_sel = lon_obj % 360
    else:
        lon_sel = lon_obj

    # Seleccionar punto más cercano
    punto = ds.sel(
        {
            lat_name: lat_obj,
            lon_name: lon_sel
        },
        method="nearest"
    )

    # Ver variables disponibles la primera vez
    if archivo == archivos[0]:
        print("Variables disponibles:")
        print(list(ds.data_vars))
        print()
        print("Punto seleccionado:")
        print("Lat:", float(punto[lat_name]))
        print("Lon:", float(punto[lon_name]))
        print()

    # Extraer viento
    if "eastward_wind" in ds.data_vars and "northward_wind" in ds.data_vars:
        u = punto["eastward_wind"].squeeze()
        v = punto["northward_wind"].squeeze()
        viento = np.sqrt(u**2 + v**2)

    elif "wind_speed" in ds.data_vars:
        viento = punto["wind_speed"].squeeze()

    else:
        raise ValueError(
            f"No encuentro variables de viento conocidas en {archivo.name}. "
            f"Variables disponibles: {list(ds.data_vars)}"
        )

    vientos.append(float(viento.values))

    ds.close()

# Crear DataFrame con una sola columna
df = pd.DataFrame({
    "viento": vientos
})

# Guardar en Excel
df.to_excel(archivo_salida, index=False)

# Media diaria
media_diaria = df["viento"].mean()

print(df)
print()
print(f"Media diaria del viento el 12 de mayo: {media_diaria:.4f} m/s")
print(f"Excel guardado en: {archivo_salida}")