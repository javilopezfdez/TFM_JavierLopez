# -*- coding: utf-8 -*-
"""
Created on Tue May 26 10:20:20 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación:26/05/2026
"""
import pandas as pd
from scipy.stats import linregress
import matplotlib.pyplot as plt

ruta_excel = r"C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\Flujos_SanSimón_2.xlsx"
ruta_salida = r"C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\Flujos_SanSimón_2_CLA_AJUSTADA.xlsx"

df = pd.read_excel(ruta_excel)

# Convertir a numerico por si hay textos, comas, espacios, etc.
df["cla_discreta"] = pd.to_numeric(df["cla_discreta"], errors="coerce")
df["VFLUOR_mV_"] = pd.to_numeric(df["VFLUOR_mV_"], errors="coerce")

# Quitar filas donde falte cualquiera de las dos variables
df_reg = df.dropna(subset=["cla_discreta", "VFLUOR_mV_"])

x = df_reg["cla_discreta"]
y = df_reg["VFLUOR_mV_"]

print("Numero de puntos usados:", len(df_reg))
print(df_reg[["cla_discreta", "VFLUOR_mV_"]].head())

slope, intercept, r_value, p_value, std_err = linregress(x, y)

print(f"Pendiente: {slope}")
print(f"Intercepto: {intercept}")
print(f"R²: {r_value**2}")
print(f"p-value: {p_value}")

# Crear columna de clorofila ajustada
# Recta: VFLUOR_mV_ = slope * cla_discreta + intercept
# Despejando: cla_ajustada = (VFLUOR_mV_ - intercept) / slope
df["cla_ajustada"] = (df["VFLUOR_mV_"] - intercept) / slope

# Guardar Excel nuevo con cla_ajustada
df.to_excel(ruta_salida, index=False)

print(f"Excel guardado con cla_ajustada en: {ruta_salida}")

y_pred = slope * x + intercept

texto_regresion = (
    f"y = {slope:.4f}x + {intercept:.4f}\n"
    f"R² = {r_value**2:.4f}"
)

plt.figure(figsize=(6, 6))
plt.scatter(x, y, label="Datos")
plt.plot(x, y_pred, color="red", label="Regresión lineal")

plt.text(
    0.05, 0.95,
    texto_regresion,
    transform=plt.gca().transAxes,
    fontsize=11,
    verticalalignment="top",
    bbox=dict(facecolor="white", alpha=0.8, edgecolor="gray")
)

plt.xlabel("cla discreta")
plt.ylabel("Voltaje fluorímetro")
plt.title("Regresión clorofila")
plt.legend()
plt.grid(True)
plt.show()
