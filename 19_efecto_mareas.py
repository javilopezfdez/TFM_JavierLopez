# -*- coding: utf-8 -*-
"""
Created on Tue May 26 11:40:38 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación:26/05/2026
"""

# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np

# ---- Rutas ----
ruta_excel = r"C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\Flujos_SanSimón_2_CLA_AJUSTADA.xlsx"
ruta_salida = r"C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\Flujos_SanSimón_MAREA.xlsx"

# ---- Columnas ----
col_salida = "salida"
col_hora = "hora_hh_mm_ss"
col_batimetria = "batimetria_m"

# ---- Datos de marea ----
mareas = {
    "SS5": {
        "t1": "07:04",
        "h1": 3.20,
        "t2": "13:05",
        "h2": 1.10,
    },
    "SS6": {
        "t1": "09:30",
        "h1": 3.00,
        "t2": "15:27",
        "h2": 1.40,
    },
    "SS7": {
        "t1": "07:09",
        "h1": 1.20,
        "t2": "13:26",
        "h2": 3.00,
    },
}


def convertir_hora(serie):
    if pd.api.types.is_numeric_dtype(serie):
        return pd.to_datetime(serie, unit="D", origin="1899-12-30")
    return pd.to_datetime(serie.astype(str), errors="coerce", dayfirst=True)


def segundos_del_dia(dt):
    return dt.dt.hour * 3600 + dt.dt.minute * 60 + dt.dt.second


def hora_a_segundos(hora_txt):
    h, m = hora_txt.split(":")
    return int(h) * 3600 + int(m) * 60


def interpolar_marea(segundos, salida):
    salida = str(salida).strip().upper()

    if salida not in mareas:
        return np.nan

    datos = mareas[salida]

    t1 = hora_a_segundos(datos["t1"])
    t2 = hora_a_segundos(datos["t2"])
    h1 = datos["h1"]
    h2 = datos["h2"]

    # Interpolación cosenoidal: la marea sube/baja más lento cerca del máximo
    # y mínimo, y más rápido en el punto medio del semiciclo (curva armónica).
    fraccion = np.clip((segundos - t1) / (t2 - t1), 0, 1)
    altura = h1 + (h2 - h1) * (1 - np.cos(np.pi * fraccion)) / 2
#MF comment: reemplazaron las dos líneas de interpolación lineal por la fórmula cosenoidal con np.clip para evitar extrapolación.
# La diferencia práctica: con la versión lineal la marea avanza a velocidad constante; ahora avanza lento al salir de pleamar/bajamar y acelera en el punto medio, que es el comportamiento real.
    return altura


# ---- Leer Excel ----
df = pd.read_excel(ruta_excel)

# Normalizar salida
df[col_salida] = df[col_salida].astype(str).str.strip().str.upper()

# Convertir batimetria y hora
df[col_batimetria] = pd.to_numeric(df[col_batimetria], errors="coerce")
df["_tiempo"] = convertir_hora(df[col_hora])
df["_segundos"] = segundos_del_dia(df["_tiempo"])

# ---- Calcular altura de marea segun SS5, SS6 o SS7 ----
df["altura_marea_m"] = df.apply(
    lambda row: interpolar_marea(row["_segundos"], row[col_salida])
    if pd.notna(row["_segundos"])
    else np.nan,
    axis=1
)

# ---- Batimetria menos altura de marea ----
df["batimetria_menos_marea_m"] = df[col_batimetria] - df["altura_marea_m"]

# Quitar auxiliares
df = df.drop(columns=["_tiempo", "_segundos"])

# Guardar
df.to_excel(ruta_salida, index=False)

print(f"Guardado en: {ruta_salida}")

print(
    df[
        [col_salida, col_hora, col_batimetria, "altura_marea_m", "batimetria_menos_marea_m"]
    ].head(20)
)
