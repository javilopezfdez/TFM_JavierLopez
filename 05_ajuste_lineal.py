# -*- coding: utf-8 -*-
"""
Created on Mon May 18 10:22:26 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación:
"""

import pandas as pd #Lectura de archivos EXCEL
import matplotlib.pyplot as plt #Graficar resultados
import numpy as np
from openpyxl import load_workbook
from openpyxl.styles import PatternFill
from scipy.stats import linregress

continuo = pd.read_excel(r"C:\Users\javil\Desktop\TFM\excel\SanSimon_6_decimal_media_movil.xlsx")
discreto = pd.read_excel(r"C:\Users\javil\Desktop\TFM\excel\SS6_discrete_samples.xlsx")

#Extraer lista de pCO2
pco2_vals = discreto["pCO2"].tolist()

contador = 0
nueva_col = []

#A cada parada 'VERDADERO' se le añade la columna de pCO2 discretos
for parada in continuo["parada"]:
    if parada == True:
        nueva_col.append(pco2_vals[contador])
        contador += 1
    else:
        nueva_col.append(None)

continuo["pCO2_discreto"] = nueva_col
continuo.to_excel(r"C:\Users\javil\Desktop\TFM\excel\SanSimon_6_CONT_DISC.xlsx", index=False)

#Cargar archivo el archivo para realizar la regresión
df = pd.read_excel(r"C:\Users\javil\Desktop\TFM\excel\SanSimon_6_CONT_DISC.xlsx")

#Quedarse solo con filas donde exista medida discreta
df_reg = df.dropna(subset=["pCO2_discreto"])

#Variables
x = df_reg["pCO2_discreto"]     # discreto
y = df_reg["pCO2"]              # continuo


#Regresión lineal
slope, intercept, r_value, p_value, std_err = linregress(x, y)

print(f"Pendiente: {slope}")
print(f"R²: {r_value**2}")
print(f"p-value: {p_value}")


#Valores ajustados
y_pred = slope * x + intercept

#Gráfico
plt.figure(figsize=(6,6))
plt.scatter(x, y, label="Datos")
plt.plot(x, y_pred, color="red", label="Regresión lineal")

plt.xlabel("pCO2 discreto")
plt.ylabel("pCO2 continuo")
plt.title("Regresión pCO2 discreto vs continuo")
plt.legend()
plt.grid(True)
plt.show()

#Crear nueva columna
df["pCO2_ajustada"] = (df["pCO2"] - intercept) / slope

#Ruta del último archivo
ruta_excel = r"C:\Users\javil\Desktop\TFM\excel\SanSimon_6_CONT_DISC.xlsx"

#Sobrescribir el mismo archivo
df.to_excel(ruta_excel, index=False)
