# -*- coding: utf-8 -*-
"""
Created on Thu May 14 11:26:49 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación: 14/05/2026
"""


df = pd.read_excel(archivo)
# Buscar el primer índice donde el barco realmente arranca
indice_1 = df[df["sog"] >= 2.4].index[0]

# Eliminar solo los datos previos al arranque
df_filtrado = df.loc[indice_1:].reset_index(drop=True)

# Guardar resultado
output = r"C:\Users\javil\Desktop\TFM\excel\SanSimon_6_decimal.xlsx"
df_filtrado.to_excel(output, index=False)
