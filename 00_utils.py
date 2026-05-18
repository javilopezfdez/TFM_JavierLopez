# -*- coding: utf-8 -*-
"""
Created on Wed May 13 12:21:56 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación: 14/05/2026
"""

import pandas as pd #Lectura de archivos EXCEL
import matplotlib.pyplot as plt #Graficar resultados
import numpy as np #Funciones matemáticas simples para estadística.
from openpyxl import load_workbook #Abrir/cargar archivos excel existentes, modificar celdas y guardar los cambios posteriormente.
from openpyxl.styles import PatternFill #Permite colorear celdas del archivo EXCEL.
from scipy.stats import linregress #Módulo para regresiones lineales.
