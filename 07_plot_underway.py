# -*- coding: utf-8 -*-
"""
Created on Wed May 13 12:20:38 2026

@author: Javier López Fernández
Contacto: javier.lopez.fernandez@alumnos.uvigo.es

Última modificación: 18/05/2026
"""

# -------------------------
# Leer archivo Excel
# -------------------------
file_path = r"C:\Users\javil\Desktop\TFM\excel\SanSimon_6_CONT_DISC.xlsx" #Se debe leer el último archivo realizado, después de los ajustes lineales a las medidas en continuo.
df = pd.read_excel(file_path)

# -------------------------
# Convertir hora
# -------------------------
df["hora_hh_mm_ss"] = pd.to_datetime(
    df["hora_hh_mm_ss"],
    format="%H:%M:%S"
)

# Ordenar por tiempo
df = df.sort_values("hora_hh_mm_ss")

# -------------------------
# Crear nueva variable
# -------------------------
df["dif_pCO2"] = df["pCO2"] - df["pCO2_ajustada"]

# -------------------------
# Crear subplots
# -------------------------
fig, axs = plt.subplots(
    6, 1,
    figsize=(14,12),
    sharex=True
)

# -------------------------
# 1. pCO2
# -------------------------
axs[0].plot(
    df["hora_hh_mm_ss"],
    df["pCO2"],
    color="blue",
    label="pCO2 crudo"
)

axs[0].plot(
    df["hora_hh_mm_ss"],
    df["pCO2_ajustada"],
    color="red",
    linestyle="--",
    label="pCO2 corregido"
)

axs[0].set_ylabel("pCO2 (µatm)")
axs[0].set_ylim(320,500)
axs[0].legend()
axs[0].grid(True)

# -------------------------
# 2. Oxígeno
# -------------------------
axs[1].plot(
    df["hora_hh_mm_ss"],
    df["sso"],
    color="green"
)

axs[1].set_ylabel("O2")
axs[1].grid(True)

# -------------------------
# 3. Temperatura
# -------------------------
axs[2].plot(
    df["hora_hh_mm_ss"],
    df["sst"],
    color="orange"
)

axs[2].set_ylabel("Temp (°C)")
axs[2].grid(True)

# -------------------------
# 4. Diferencia pCO2
# -------------------------
axs[3].plot(
    df["hora_hh_mm_ss"],
    df["dif_pCO2"],
    color="black"
)

axs[3].set_ylabel("ΔpCO2\n(µatm)")
axs[3].grid(True)

# -------------------------
# 5. Salinidad
# -------------------------
axs[4].plot(
    df["hora_hh_mm_ss"],
    df["sss"],
    color="purple"
)

axs[4].set_ylabel("Salinidad")
axs[4].grid(True)

# -------------------------
# 6. Clorofila
# -------------------------
axs[5].plot(
    df["hora_hh_mm_ss"],
    df["cla"],
    color="darkgreen",
    linewidth=1
)

axs[5].set_ylabel("Clorofila")
axs[5].set_ylim(0,0.2)
axs[5].set_xlabel("Hora")
axs[5].grid(True)

# -------------------------
# Título general
# -------------------------
plt.suptitle("Serie temporal de las distintas variables.", fontsize=14)

plt.tight_layout()
plt.show()
