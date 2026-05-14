# -*- coding: utf-8 -*-
"""
Created on Thu May 14 11:26:49 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación: 14/05/2026
"""

df = pd.read_excel(archivo)
#-----Se establece arbitrariamente el valor 2.4 de 'speed over ground' del barco, a partir del cual se empieza a trabajar-----------------
indice_1 = df[df["sog"] >= 2.4].index[0]

#----------Se eliminan los valores que son previos al arranque del barco-----------------
df_filtrado = df.loc[indice_1:].reset_index(drop=True)

#-------Se guarda el resultado----------------
output = r"C:\Users\javil\Desktop\TFM\excel\SanSimon_6_decimal.xlsx"
df_filtrado.to_excel(output, index=False)
