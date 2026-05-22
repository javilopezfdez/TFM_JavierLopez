# -*- coding: utf-8 -*-
"""
Created on Wed May 20 13:07:01 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación: 21/05/2026
"""

import pandas as pd
import matplotlib.pyplot as plt

archivo = r"C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\SS7_FLUJOS_BAT_VIENTOS.xlsx"

df = pd.read_excel(archivo)

df["hora_hh_mm_ss"] = pd.to_datetime(
    df["hora_hh_mm_ss"],
    format="%H:%M:%S",
    errors="coerce"
)

df["diferencia"] = df["ws"] - df["ws_cop"]
df["diferencia_1"] = df["ws"] - df["viento_m_s"]

fig, ax = plt.subplots(2, 1, figsize=(10, 7), sharex=True)

ax[0].plot(
    df["hora_hh_mm_ss"],
    df["ws"],
    label="Viento_METEOGALICIA_MOD"
)
ax[0].plot(
    df["hora_hh_mm_ss"],
    df["ws_cop"],
    label="Viento_COPERNICUS"
)
ax[0].plot(
    df["hora_hh_mm_ss"],
    df["viento_m_s"],
    label="Viento_OViso"
)
ax[0].set_ylabel("Viento")
ax[0].set_title("Viento vs tiempo")
ax[0].legend()
ax[0].grid(True)

ax[1].plot(
    df["hora_hh_mm_ss"],
    df["diferencia"],
    color="black",
    label="Diferencia METEOGALICIA_MOD - COPERNICUS"
)
ax[1].plot(
    df["hora_hh_mm_ss"],
    df["diferencia_1"],
    color="blue",
    label="Diferencia METEOGALICIA_MOD - O Viso"
)
ax[1].axhline(0, color="gray", linestyle="--", linewidth=1)
ax[1].set_xlabel("Tiempo")
ax[1].set_ylabel("Diferencia vientos")
ax[1].legend()
ax[1].grid(True)

plt.tight_layout()
plt.show()
