# -*- coding: utf-8 -*-
"""
Created on Fri May 15 10:26:26 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación: 15/05/2026
"""

#Las paradas y las horas se promedian de una forma distinta 
columnas_datos = df_final.select_dtypes(include=[np.number]).columns.tolist()

df_procesado_lista = []
buffer_movimiento = []

for idx, row in df_final.iterrows():
    if row['parada'] == True:
        #Si hay datos en el buffer de movimiento, procesarlos antes de la parada
        if buffer_movimiento:
            temp_df = pd.DataFrame(buffer_movimiento)
            # Agrupar cada 12 filas (1 minuto)
            # Usamos floor division para crear grupos de 12
            temp_df['grupo'] = np.arange(len(temp_df)) // 12
            
            #Promediar grupos
            resumen_mov = temp_df.groupby('grupo').mean(numeric_only=True)
            # Recuperar la columna 'parada' como False y la hora (tomamos la primera del bloque)
            resumen_mov['parada'] = False
            resumen_mov['hora_hh_mm_ss'] = temp_df.groupby('grupo')['hora_hh_mm_ss'].first().values
            
            df_procesado_lista.append(resumen_mov)
            buffer_movimiento = []
        
        #Añadir la parada tal cual
        df_procesado_lista.append(pd.DataFrame([row]))
    else:
        buffer_movimiento.append(row)

#No perder ningún dato.
if buffer_movimiento:
    temp_df = pd.DataFrame(buffer_movimiento)
    temp_df['grupo'] = np.arange(len(temp_df)) // 12
    resumen_mov = temp_df.groupby('grupo').mean(numeric_only=True)
    resumen_mov['parada'] = False
    resumen_mov['hora_hh_mm_ss'] = temp_df.groupby('grupo')['hora_hh_mm_ss'].first().values
    df_procesado_lista.append(resumen_mov)

#Unificación del EXCEL.
df_suavizado = pd.concat(df_procesado_lista, ignore_index=True)

#Tener orden coherente en las columnas
cols = [c for c in df_final.columns if c in df_suavizado.columns]
df_suavizado = df_suavizado[cols]

#Guardar EXCEL
output_suavizado = r"C:\Users\javil\Desktop\TFM\excel\SanSimon_6_decimal_media_movil.xlsx"
#Conversión de las horas.
df_suavizado['hora_hh_mm_ss'] = df_suavizado['hora_hh_mm_ss'].dt.strftime('%H:%M:%S')

df_suavizado.to_excel(output_suavizado, index=False)

#Se aplica de nuevo los colores  las estaciones
wb = load_workbook(output_suavizado)
ws = wb.active
azul = PatternFill(fill_type="solid", start_color="DDEBF7", end_color="DDEBF7")

col_parada = None
for col in range(1, ws.max_column + 1):
    if ws.cell(row=1, column=col).value == "parada":
        col_parada = col
        break

for row in range(2, ws.max_row + 1):
    if ws.cell(row=row, column=col_parada).value == True:
        for col in range(1, ws.max_column + 1):
            ws.cell(row=row, column=col).fill = azul

#Se guarda el EXCEL.
wb.save(output_suavizado)