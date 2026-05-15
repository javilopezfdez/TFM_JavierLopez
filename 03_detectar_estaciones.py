# -*- coding: utf-8 -*-
"""
Created on Thu May 14 22:51:18 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación:14/05/2026
"""

df["sog"] = pd.to_numeric(df["sog"], errors="coerce")
df["hora_hh_mm_ss"] = pd.to_datetime(df["hora_hh_mm_ss"], format="%H:%M:%S")


indices_finales = []
indices_paradas = []

i = 0

while i < len(df): #Se detectan las estaciones (barco a una SOG<2.4 durante, mínimo, 3 minutos)

    if df.loc[i, "sog"] < 2.4:
        inicio = i

        while i < len(df) and df.loc[i, "sog"] < 2.4:
            i += 1

        fin = i - 1

        duracion = (
            df.loc[fin, "hora_hh_mm_ss"] -
            df.loc[inicio, "hora_hh_mm_ss"]
        ).total_seconds() / 60

        if duracion >= 3:
            #Al ser una parada, se conserva un único valor (el central, arbitrariamente) como valor representativo de la zona, para después compararlo con la medida discreta.
            centro = (inicio + fin) // 2
            indices_finales.append(centro)
            indices_paradas.append(centro)
        else:
            #Si no se llega a 3 minutos, se conservan los valores
            indices_finales.extend(range(inicio, fin + 1))

    else:
        indices_finales.append(i)
        i += 1

#----Los siguientes condicionales indican que tanto la primera como la última fila cuentan de forma automática como estación.
if 0 not in indices_finales:
    indices_finales.append(0)
    indices_paradas.append(0)


ultimo = len(df) - 1
if ultimo not in indices_finales:
    indices_finales.append(ultimo)
    indices_paradas.append(ultimo)

#Se ordenan las filas para que el ajuste no quede en distinto orden cronológico.
indices_finales = sorted(set(indices_finales))
indices_paradas = sorted(set(indices_paradas))


df_final = df.loc[indices_finales].reset_index(drop=True)

#Guarda en la memoria las filas que son el valor representativo de cada estación.
df_final["parada"] = False

indices_originales = df.loc[indices_finales].index.tolist()

for i, idx_original in enumerate(indices_originales):
    if idx_original in indices_paradas:
        df_final.loc[i, "parada"] = True

df_final["hora_hh_mm_ss"] = df_final["hora_hh_mm_ss"].dt.strftime("%H:%M:%S") #Este paso simplemente deja la columna de la hora de la medida en formato hh_mm_ss

#Se guarda el EXCEL
output = r"C:\Users\javil\Desktop\TFM\excel\SanSimon_6_decimal_paradas_filtrado.xlsx"
df_final.to_excel(output, index=False)

#Se colorean las paradas para poder identificarlas fácil visualmente en la hoja de cálculos.
wb = load_workbook(output)
ws = wb.active

azul = PatternFill(
    fill_type="solid",
    start_color="DDEBF7",
    end_color="DDEBF7"
)

col_parada = None
for col in range(1, ws.max_column + 1):
    if ws.cell(row=1, column=col).value == "parada":
        col_parada = col
        break

for row in range(2, ws.max_row + 1):
    if ws.cell(row=row, column=col_parada).value == True:
        for col in range(1, ws.max_column + 1):
            ws.cell(row=row, column=col).fill = azul

#Se guarda la modificación realizada sobre el EXCEL.
wb.save(output)
