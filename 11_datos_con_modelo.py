# -*- coding: utf-8 -*-
"""
Created on Tue May 19 10:46:12 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación: 19/05/2026
"""

import numpy as np
import pandas as pd
import xarray as xr
from scipy.interpolate import LinearNDInterpolator, NearestNDInterpolator
from scipy.spatial import cKDTree
from functools import lru_cache
from pathlib import Path
from datetime import datetime, time, timedelta

# =====================
# CONFIGURACION
# =====================

NETCDF_PATH = r"C:\Users\javil\Downloads\wrf_arw_det_history_d02_20260512_0000.nc4.nc"
EXCEL_PATH = r"C:\Users\javil\Desktop\TFM\excel\SanSimon_6_CONT_DISC.xlsx"

SHEET_NAME = 0

# Columnas del Excel
TIME_COL = "hora_hh_mm_ss"
LAT_COL = "lat"
LON_COL = "longitud"

# Fecha UTC del modelo y de las horas del Excel
DATE_UTC = "2026-05-12"

# "linear" interpola espacialmente en lat/lon.
# "nearest" usa el punto de malla mas cercano.
SPATIAL_METHOD = "linear"

# "linear" interpola entre salidas temporales del modelo.
# "nearest" usa la hora de modelo mas cercana.
TIME_METHOD = "linear"

OUT_PATH = r"C:\Users\javil\Desktop\TFM\excel\SALIDA_CON_VIENTOS.xlsx"

# =====================
# FUNCIONES
# =====================

def parse_excel_time(value, date_utc):
    base_date = pd.Timestamp(date_utc)

    if pd.isna(value):
        return pd.NaT

    if isinstance(value, pd.Timestamp):
        if value.year < 1905:
            return base_date + pd.to_timedelta(
                value.hour * 3600 + value.minute * 60 + value.second,
                unit="s"
            )
        return value

    if isinstance(value, datetime):
        if value.year < 1905:
            return base_date + pd.to_timedelta(
                value.hour * 3600 + value.minute * 60 + value.second,
                unit="s"
            )
        return pd.Timestamp(value)

    if isinstance(value, time):
        return base_date + pd.to_timedelta(
            value.hour * 3600 + value.minute * 60 + value.second,
            unit="s"
        )

    if isinstance(value, timedelta):
        return base_date + pd.to_timedelta(value)

    if isinstance(value, (int, float, np.integer, np.floating)):
        # Excel puede guardar una hora como fraccion de dia.
        return base_date + pd.to_timedelta(float(value), unit="D")

    txt = str(value).strip()
    parsed = pd.to_datetime(txt, errors="coerce")

    if pd.isna(parsed):
        raise ValueError(f"No puedo interpretar la hora: {value!r}")

    if parsed.year < 1905 or txt.count(":") >= 1:
        return base_date + pd.to_timedelta(
            parsed.hour * 3600 + parsed.minute * 60 + parsed.second,
            unit="s"
        )

    return parsed


#------------Lectura de datos---------------------------

df = pd.read_excel(EXCEL_PATH, sheet_name=SHEET_NAME)

ds = xr.open_dataset(NETCDF_PATH, decode_times=False)

lat_grid = ds["lat"].values
lon_grid = ds["lon"].values
mod = ds["mod"]

time_seconds = ds["time"].values.astype(float)
time_origin = pd.Timestamp(DATE_UTC)
model_times = time_origin + pd.to_timedelta(time_seconds, unit="s")

points = np.column_stack([lon_grid.ravel(), lat_grid.ravel()])
tree = cKDTree(points)


@lru_cache(maxsize=None)
def linear_interp_for_time(t_index):
    values = mod.isel(time=t_index).values.ravel()
    return LinearNDInterpolator(points, values)


@lru_cache(maxsize=None)
def nearest_interp_for_time(t_index):
    values = mod.isel(time=t_index).values.ravel()
    return NearestNDInterpolator(points, values)


def spatial_value(t_index, lat, lon):
    if SPATIAL_METHOD == "nearest":
        return float(nearest_interp_for_time(t_index)(lon, lat))

    value = linear_interp_for_time(t_index)(lon, lat)

    if np.isnan(value):
        value = nearest_interp_for_time(t_index)(lon, lat)

    return float(value)


def model_value_at(lat, lon, obs_time):
    obs_seconds = (obs_time - time_origin).total_seconds()

    if obs_seconds < time_seconds.min() or obs_seconds > time_seconds.max():
        return np.nan

    if TIME_METHOD == "nearest":
        it = int(np.argmin(np.abs(time_seconds - obs_seconds)))
        return spatial_value(it, lat, lon)

    i_after = int(np.searchsorted(time_seconds, obs_seconds))

    if i_after == 0:
        return spatial_value(0, lat, lon)

    if i_after >= len(time_seconds):
        return spatial_value(len(time_seconds) - 1, lat, lon)

    i_before = i_after - 1

    t0 = time_seconds[i_before]
    t1 = time_seconds[i_after]

    v0 = spatial_value(i_before, lat, lon)
    v1 = spatial_value(i_after, lat, lon)

    weight = (obs_seconds - t0) / (t1 - t0)
    return float(v0 + weight * (v1 - v0))



#--------------------------CÁLCULOS------------------------------------------


obs_times = df[TIME_COL].apply(lambda x: parse_excel_time(x, DATE_UTC))

wind_ms = []
nearest_grid_lat = []
nearest_grid_lon = []
nearest_grid_dist_deg = []

for i in range(len(df)):
    lat = float(df.loc[i, LAT_COL])
    lon = float(df.loc[i, LON_COL])
    obs_time = obs_times.iloc[i]

    wind_ms.append(model_value_at(lat, lon, obs_time))

    dist, idx = tree.query([lon, lat])
    nearest_grid_lon.append(points[idx, 0])
    nearest_grid_lat.append(points[idx, 1])
    nearest_grid_dist_deg.append(dist)

df["hora_modelo_utc_usada"] = obs_times
df["ws"] = wind_ms
df["lat_malla_mas_cercana"] = nearest_grid_lat
df["lon_malla_mas_cercana"] = nearest_grid_lon
df["dist_malla_mas_cercana_grados"] = nearest_grid_dist_deg

df.to_excel(OUT_PATH, index=False)

print(f"Archivo creado: {OUT_PATH}")