# -*- coding: utf-8 -*-
"""
Created on Wed May 13 12:21:56 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación: 20/05/2026
"""

import pandas as pd #Lectura de archivos EXCEL
import matplotlib.pyplot as plt #Graficar resultados
import numpy as np #Funciones matemáticas simples para estadística.
from openpyxl import load_workbook #Abrir/cargar archivos excel existentes, modificar celdas y guardar los cambios posteriormente.
from openpyxl.styles import PatternFill #Permite colorear celdas del archivo EXCEL.
from scipy.stats import linregress #Módulo para regresiones lineales.
import xarray as xr  # Manejo de datos multidimensionales (NetCDF, clima, matrices etiquetadas)
from scipy.interpolate import LinearNDInterpolator, NearestNDInterpolator
# LinearNDInterpolator -> interpolación lineal en múltiples dimensiones
# NearestNDInterpolator -> interpolación usando el punto más cercano
from scipy.spatial import cKDTree  #Búsqueda rápida de vecinos/puntos cercanos
from functools import lru_cache  #Almacena resultados para evitar cálculos repetidos
from pathlib import Path  #Manejo de rutas y archivos
from datetime import datetime, time, timedelta
# datetime -> fechas y horas completas
# time -> solo horas/minutos/segundos
# timedelta -> diferencias o sumas de tiempo
from FCO2_functions import kCO2, sco2, prevapor #Cálculos de flujos de CO2
