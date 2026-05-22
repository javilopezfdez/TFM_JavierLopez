# -*- coding: utf-8 -*-
"""
Created on Wed May 20 17:50:39 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación: 21/05/2026
"""

import numpy as np
import pandas as pd
from FCO2_functions import kCO2, sco2, prevapor

# Assume df is a pandas DataFrame with columns:
# - 'ws': wind speed at 10 m (m/s)
# - 'thetao_cmems': potential temperature (°C) from CMEMS
# - 'so_cmems': salinity (PSU) from CMEMS
# - 'fCO2_sw': sea-surface fCO2 (μatm)
# - 'fCO2_atm': atmospheric fCO2 (μatm)
# - 'deltafCO2': pre-computed fCO2 gradient (μatm)

df = pd.read_excel(r"C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\SS7_FLUJOS_BAT_VIENTOS.xlsx")


# ================================================================
# 1. COMPUTE GAS TRANSFER VELOCITY (kw)
# ================================================================
# kw represents the rate of gas exchange normalized to a 
# reference Schmidt number of 660 K. Option 22 uses the 
# Wanninkhof (1992) revisited parameterization.

transfer_velocity_option = 22
df['kw_viso'] = kCO2(
    ws=df['viento_m_s'], 
    TC=df['sst'], 
    option=transfer_velocity_option
)
print(f"Gas transfer velocity (kw) range: {df['kw'].min():.2f} – {df['kw'].max():.2f} cm/h")

# ================================================================
# 2. COMPUTE CO2 SOLUBILITY (SCO2)
# ================================================================
# SCO2 is the saturation concentration of dissolved CO2 in 
# seawater. Higher temperatures reduce solubility (e.g., tropical 
# waters outgas more readily than polar waters at equal ΔfCO2).

df['SCO2'] = sco2(
    TC=df['sst'], 
    S=df['sss']
)
print(f"CO2 solubility (SCO2) range: {df['SCO2'].min():.4f} – {df['SCO2'].max():.4f} mol/kg/atm")

# ================================================================
# 3. COMPUTE FUGACITY DIFFERENCE (ΔfCO2)
# ================================================================
# The fugacity difference is the thermodynamic driver for flux.
# Pre-computed from discrete fCO2 measurements or model output.

df['deltafCO2'] = df['pCO2_ajustada'] - df['fCO2_atm']
n_source = (df['deltafCO2'] > 0).sum()
n_sink = (df['deltafCO2'] < 0).sum()
print(f"Source pixels (ΔfCO2 > 0): {n_source}; Sink pixels (ΔfCO2 < 0): {n_sink}")

# ================================================================
# 4. COMPUTE AIR–SEA CO2 FLUX (FCO2)
# ================================================================
# FCO2 = kw × SCO2 × ΔfCO2 × 0.24
# 
# The factor 0.24 converts:
#   - kw from cm/h to m/d: 0.01 m/cm × 24 h/d = 0.24 m/d
#   - Combined with density and stoichiometric factors for CO2
#
# Output units: mmol C m−2 d−1

df['FCO2_v'] = df['kw_viso'] * df['SCO2'] * df['deltafCO2'] * 0.24

# print(f"CO2 flux (FCO2) range: {df['FCO2'].min():.2f} – {df['FCO2'].max():.2f} mmol/m²/d")
# print(f"Mean CO2 flux: {df['FCO2'].mean():.2f} mmol/m²/d")

# ================================================================
# 5. CONVERT TO ANNUAL INTEGRATED FLUX
# ================================================================
# Convert from daily mmol to annual mol:
#   - Divide by 1000 to convert mmol → mol
#   - Multiply by 365.25 days/year for leap-year correction
#
# Output units: mol C m−2 yr−1


df['FCO2_viso'] = (df['FCO2_v'] / 1000) * 365.25

#print(f"Annual CO2 flux range: {df['FCO2_molCm2yr'].min():.4f} – {df['FCO2_molCm2yr'].max():.4f} mol/m²/yr")
#print(f"Annual CO2 flux range: {df['FCO2_cop'].min():.4f} – {df['FCO2_cop'].max():.4f} mol/m²/yr")
# ================================================================
# 6. SAVE FCO2 TO THE SAME EXCEL FILE
# ================================================================

ruta_excel = r"C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\SS7_FLUJOS_BAT_VIENTOS.xlsx"

# Sobrescribir el mismo archivo con la nueva columna FCO2
df.to_excel(ruta_excel, index=False)

print("Columna 'FCO2' añadida correctamente al Excel.")
