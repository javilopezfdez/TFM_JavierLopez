# -*- coding: utf-8 -*-
"""
Created on Wed Jun  3 09:01:54 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación:03/06/2023
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from datetime import datetime
import os

# =========================
# ARCHIVOS
# =========================
archivos = {
    "SS5": r"C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\Agrupar\SS5_FLUJOS_BAT_VIENTOS.xlsx",
    "SS6": r"C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\Agrupar\SS6_FLUJOS_BAT_VIENTOS.xlsx",
    "SS7": r"C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\Agrupar\SS7_FLUJOS_BAT_VIENTOS.xlsx",
}

orden_salidas = ["SS5", "SS6", "SS7"]

fechas_titulo = {
    "SS5": "6th April 2026",
    "SS6": "23rd April 2026",
    "SS7": "12th May 2026",
}

limites_hora = {
    "SS5": (datetime(2000, 1, 1, 7, 15), datetime(2000, 1, 1, 11, 0)),
    "SS6": (datetime(2000, 1, 1, 7, 45), datetime(2000, 1, 1, 11, 20)),
    "SS7": (datetime(2000, 1, 1, 8, 0), datetime(2000, 1, 1, 11, 0)),
}

# =========================
# CARPETA DE SALIDA
# =========================
output_dir = r"C:\Users\javil\Desktop\TFM\FIGURAS\importantes\SeriesTemporales"

# =========================
# COLORES
# =========================
color_sst  = (0.50, 0.20, 0.75)
color_sss  = (0.10, 0.60, 0.25)
color_o2   = (0.95, 0.35, 0.70)
color_pco2 = (0.20, 0.65, 0.95)

# =========================
# LOOP
# =========================
for salida in orden_salidas:

    archivo = archivos[salida]
    hora_inicio, hora_fin = limites_hora[salida]

    df = pd.read_excel(archivo)
    df.columns = df.columns.str.strip()

    # -------------------------
    # VARIABLES
    # -------------------------
    sst = pd.to_numeric(df["sst"], errors="coerce")
    sss = pd.to_numeric(df["sss"], errors="coerce")
    sso = pd.to_numeric(df["sso"], errors="coerce")
    pco2 = pd.to_numeric(df["pCO2_ajustada"], errors="coerce")
    fco2 = pd.to_numeric(df["fCO2_atm"], errors="coerce")

    if "pCO2_discreto" in df.columns:
        pdisc = pd.to_numeric(df["pCO2_discreto"], errors="coerce")
    else:
        pdisc = np.full(len(df), np.nan)

    # -------------------------
    # TIEMPO
    # -------------------------
    hora_raw = df.get("hora_hh_mm_ss", df.get("hora"))
    hora = pd.to_datetime(hora_raw, errors="coerce")

    base = pd.Timestamp("2000-01-01")

    hora_plot = base + (
        hora.dt.hour * pd.Timedelta(hours=1) +
        hora.dt.minute * pd.Timedelta(minutes=1) +
        hora.dt.second * pd.Timedelta(seconds=1)
    )

    # -------------------------
    # ORDENAR
    # -------------------------
    idx = np.argsort(hora_plot)

    hora_plot = hora_plot.iloc[idx]
    sst = sst.iloc[idx]
    sss = sss.iloc[idx]
    sso = sso.iloc[idx]
    pco2 = pco2.iloc[idx]
    fco2 = fco2.iloc[idx]
    pdisc = pdisc[idx]

    # =========================
    # FIGURA
    # =========================
    fig = plt.figure(figsize=(12, 6))

    ax1 = fig.add_axes([0.10, 0.15, 0.80, 0.70])

    ax1.set_xlim(hora_inicio, hora_fin)

    # SST
    line1, = ax1.plot(
        hora_plot, sst,
        '-o',
        color=color_sst,
        markersize=3,
        linewidth=1.2,
        label="Sea Surface Temperature"
    )

    ax1.set_ylabel("Sea Surface Temperature (°C)", color=color_sst)
    ax1.set_xlabel("Time", fontsize=14, labelpad=10)
    ax1.tick_params(axis='y', colors=color_sst)

    # SSS
    ax2 = ax1.twinx()

    line2, = ax2.plot(
        hora_plot, sss,
        '-o',
        color=color_sss,
        markersize=3,
        linewidth=1.2,
        label="Sea Surface Salinity"
    )

    ax2.set_ylabel("Salinity", color=color_sss)
    ax2.tick_params(axis='y', colors=color_sss)

    # O2
    ax3 = ax1.twinx()
    ax3.spines["right"].set_position(("axes", 1.08))

    line3, = ax3.plot(
        hora_plot, sso,
        '-o',
        color=color_o2,
        markersize=3,
        linewidth=1.2,
        label="O$_2$"
    )

    ax3.set_ylabel("Sea Surface Oxygen (mg L$^{-1}$)", color=color_o2)
    ax3.tick_params(axis='y', colors=color_o2)

    # pCO2
    ax4 = ax1.twinx()
    ax4.spines["right"].set_position(("axes", 1.16))

    line4, = ax4.plot(
        hora_plot, pco2,
        '-o',
        color=color_pco2,
        markersize=3,
        linewidth=1.2,
        label="pCO$_2$"
    )

    idx_disc = ~np.isnan(pdisc)

    ax4.plot(
        hora_plot[idx_disc],
        pdisc[idx_disc],
        'o',
        markerfacecolor='none',
        markeredgecolor='k',
        markersize=6
    )

    ax4.set_ylabel(r"Sea Surface pCO$_2$ ($\mu$atm)", color=color_pco2)
    ax4.tick_params(axis='y', colors=color_pco2)

    # fCO2
    ax5 = ax1.twinx()
    ax5.spines["right"].set_position(("axes", 1.24))

    line5, = ax5.plot(
        hora_plot,
        fco2,
        '--',
        color='black',
        linewidth=1.2,
        label="fCO$_2$"
    )

    ax5.set_ylabel(r"Atmospheric fCO$_2$ ($\mu$atm)", color='black')
    ax5.tick_params(axis='y', colors='black')

    # =========================
    # EJE X SOLO HORAS
    # =========================
    ax1.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M"))

    # =========================
    # LEYENDA
    # =========================
    fig.legend(
        [line1, line2, line3, line4, line5],
        ["Temperature", "Salinity", "O$_2$", "pCO$_2$", "Atmospheric fCO$_2$"],
        loc="upper center",
        bbox_to_anchor=(0.5, 0.98),
        ncol=5,
        frameon=False
    )

    # Deja espacio para la leyenda
    plt.subplots_adjust(top=0.88)
    # =========================
    # GUARDAR PDF
    # =========================
    # pdf_path = os.path.join(output_dir, f"{salida}.pdf")

    # plt.savefig(pdf_path,format='pdf', bbox_inches='tight')
    fig.savefig(
    os.path.join(output_dir, f"{salida}.png"),
    dpi=2400,
    bbox_inches="tight",
    facecolor="white"
)
    
    plt.show()


    plt.close()

