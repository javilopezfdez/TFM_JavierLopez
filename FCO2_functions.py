"""
Generic functions for dealing with FCO2-related phenomena.

Module for CO2 flux calculations and related oceanographic parameters.
Includes functions for water vapor pressure, CO2 gas transfer velocity,
CO2 solubility, and atmospheric xCO2 data loading from NOAA NetCDF files.

Author: Marcos Fontela, originally in R language. Translated by IA. Consider as is.
Language: Python 3.8+
Dependencies: numpy, pandas, xarray, netCDF4
"""

import numpy as np
import pandas as pd
import xarray as xr
import warnings


def prevapor(TC, SSS):
    """
    Calculate water vapor pressure as a function of temperature and salinity.
    
    Implements the empirical relationship for saturated water vapor pressure
    accounting for salinity effects (salting-out phenomenon).
    
    Parameters
    ----------
    TC : float or array-like
        Temperature in degrees Celsius
    SSS : float or array-like
        Sea Surface Salinity in PSU (Practical Salinity Units)
    
    Returns
    -------
    pH2O : float or numpy.ndarray
        Water vapor pressure in appropriate units (consistent with input types)
    
    Notes
    -----
    The salinity correction implements the Weiss and Price (1980) approach
    to account for reduced vapor pressure in seawater.
    """
    TK = TC + 273.15
    pH2O = np.exp(24.4543 - 67.4509 * (100 / TK) - 4.8489 * np.log(TK / 100) 
                  - 0.000544 * SSS)
    return pH2O


def kCO2(ws, TC, option=22):
    """
    Calculate the CO2 gas transfer velocity (piston velocity).
    
    Implements multiple parameterizations relating wind speed and temperature
    to the gas transfer coefficient. The function supports 22 different
    published parameterizations from the literature.
    
    Parameters
    ----------
    ws : float or numpy.ndarray
        Wind speed at 10 m height in m/s. Must have same shape as TC.
    TC : float or numpy.ndarray
        Temperature in degrees Celsius. Must have same shape as ws.
    option : int, optional
        Parameterization selection (1-22). Default is 22.
        
        - 1 : Wanninkhof (1992) - short time scales
        - 2 : Wanninkhof (1992) - long time scales
        - 3 : Nightingale (2000)
        - 4 : Naegler et al. (2006) NCEP monthly (5°x4°)
        - 5 : Naegler et al. (2006) ECMWF monthly (5°x4°)
        - 6 : Naegler et al. (2006) SSMI monthly (5°x4°)
        - 7 : Naegler et al. (2006) QSCAT monthly (5°x4°)
        - 8 : Naegler et al. (2006) ERS12 monthly (5°x4°)
        - 9 : Naegler et al. (2006) NCEP monthly (1°x1°)
        - 10 : Naegler et al. (2006) ECMWF monthly (1°x1°)
        - 11 : Naegler et al. (2006) SSMI monthly (1°x1°)
        - 12 : Naegler et al. (2006) QSCAT monthly (1°x1°)
        - 13 : Naegler et al. (2006) ERS12 monthly (1°x1°)
        - 14 : Naegler et al. (2006) NCEP daily (1°x1°)
        - 15 : Naegler et al. (2006) ECMWF daily (1°x1°)
        - 16 : Ho et al. (2006)
        - 17 : Wanninkhof & McGillis (1999) - steady, short-term winds [NOTE: incomplete]
        - 18 : McGillis et al. (2001)
        - 19 : McGillis et al. (2004)
        - 20 : Sweeney et al. (2007)
        - 21 : Liss and Merlivat (1986) - piecewise parameterization
        - 22 : Wanninkhof (1992) revisited [DEFAULT]
    
    Returns
    -------
    kw : float or numpy.ndarray
        CO2 gas transfer velocity (piston velocity) in cm/hr at reference
        temperature and salinity. Shape matches input arrays.
    
    Raises
    ------
    ValueError
        If ws and TC do not have compatible dimensions (for array inputs).
    UserWarning
        If option is not in the valid range (1-22).
    
    Notes
    -----
    The function accounts for temperature-dependent Schmidt number scaling
    using the Smith (1985) parameterization of Schmidt number vs. temperature.
    Reference temperatures are 660 K (for most parameterizations) or 600 K
    (for some alternatives).
    
    Original MATLAB code translated via AI; substantial improvements possible.
    """
    # Convert to numpy arrays for vectorization
    ws = np.asarray(ws)
    TC = np.asarray(TC)
    
    # Check dimension compatibility
    if ws.shape != TC.shape:
        raise ValueError("ws and TC must have compatible dimensions")
    
    # Schmidt number calculation via Smith (1985) polynomial
    Smith = 2073.1 - 125.62 * TC + 3.6276 * TC**2 - 0.043219 * TC**3
    S660 = np.sqrt(660 / Smith)
    S600 = np.sqrt(600 / Smith)
    
    # Initialize output array
    kw = np.full_like(ws, np.nan, dtype=float)
    
    # Parameterization selection
    if option == 1:
        # Wanninkhof (1992) short time scales
        kw = (0.31 * ws**2) * S660
    elif option == 2:
        # Wanninkhof (1992) long time scales
        kw = (0.39 * ws**2) * S660
    elif option == 3:
        # Nightingale (2000)
        kw = ((0.333 * ws) + (0.222 * ws**2)) * S600
    elif option == 4:
        # NCEP monthly (5°x4°)
        kw = (0.4 * ws**2) * S660
    elif option == 5:
        # ECMWF monthly (5°x4°)
        kw = (0.35 * ws**2) * S660
    elif option == 6:
        # SSMI monthly (5°x4°)
        kw = (0.29 * ws**2) * S660
    elif option == 7:
        # QSCAT monthly (5°x4°)
        kw = (0.29 * ws**2) * S660
    elif option == 8:
        # ERS12 monthly (5°x4°)
        kw = (0.34 * ws**2) * S660
    elif option == 9:
        # NCEP monthly (1°x1°)
        kw = (0.39 * ws**2) * S660
    elif option == 10:
        # ECMWF monthly (1°x1°)
        kw = (0.34 * ws**2) * S660
    elif option == 11:
        # SSMI monthly (1°x1°)
        kw = (0.28 * ws**2) * S660
    elif option == 12:
        # QSCAT monthly (1°x1°)
        kw = (0.27 * ws**2) * S660
    elif option == 13:
        # ERS12 monthly (1°x1°)
        kw = (0.32 * ws**2) * S660
    elif option == 14:
        # NCEP daily (1°x1°)
        kw = (0.38 * ws**2) * S660
    elif option == 15:
        # ECMWF daily (1°x1°)
        kw = (0.33 * ws**2) * S660
    elif option == 16:
        # Ho et al. (2006)
        kw = (0.266 * ws**2) * S600
    elif option == 17:
        # Wanninkhof & McGillis (1999) steady, short-term winds
        # NOTE: Original implementation incomplete; S_cte undefined
        warnings.warn("Option 17 has undefined parameter (S_cte). Output may be invalid.", 
                     UserWarning)
        kw = (0.0283 * ws**3)  # Placeholder: S_cte missing
    elif option == 18:
        # McGillis et al. (2001)
        kw = (3.3 + 0.026 * ws**3) * S660
    elif option == 19:
        # McGillis et al. (2004)
        kw = (8.8 + 0.026 * ws**3) * S660
    elif option == 20:
        # Sweeney et al. (2007)
        kw = (0.27 * ws**2) * S660
    elif option == 21:
        # Liss and Merlivat (1986) - piecewise parameterization
        kw = np.full_like(ws, np.nan, dtype=float)
        for ii in np.ndindex(ws.shape):
            Smith_i = 2073.1 - 125.62 * TC[ii] + 3.6276 * TC[ii]**2 - 0.043219 * TC[ii]**3
            S600_i = np.sqrt(600 / Smith_i)
            if ws[ii] < 3.6:
                kw[ii] = 0.17 * ws[ii] * S600_i
            elif ws[ii] > 13:
                kw[ii] = (5.9 * ws[ii] - 49.3) * S600_i
            else:
                kw[ii] = (2.85 * ws[ii] - 9.65) * S600_i
    elif option == 22:
        # Wanninkhof (1992) revisited (DEFAULT)
        kw = (0.251 * ws**2) * S660
    else:
        warnings.warn(f"Invalid option {option}. Valid range is 1-22.", UserWarning)
    
    # Return scalar if input was scalar
    if kw.shape == ():
        return float(kw)
    
    return kw


def sco2(TC, S):
    """
    Estimate the solubility of CO2 in seawater.
    
    Calculates the saturation concentration of dissolved CO2 based on
    temperature and salinity using the Weiss (1974) parameterization.
    
    Parameters
    ----------
    TC : float or array-like
        Temperature in degrees Celsius
    S : float or array-like
        Salinity in PSU (Practical Salinity Units)
    
    Returns
    -------
    sol : float or numpy.ndarray
        CO2 solubility in mol/(L·atm). Units consistent with input types.
    
    Notes
    -----
    The solubility is temperature- and salinity-dependent, with the
    salinity effect accounting for the ionic strength effect on gas
    solubility (Weiss, 1974). Valid for typical oceanic conditions.
    
    References
    ----------
    Weiss, R. F. (1974). Carbon dioxide in water and seawater: The solubility
    of a non-ideal gas. Marine Chemistry, 2(3), 203-215.
    """
    sol = np.exp(-167.81077 + 9345.17 / (TC + 273.15) 
                 + 23.3585 * np.log(TC + 273.15) 
                 + S * (0.023517 - 0.00023656 * (TC + 273.15) 
                        + 0.0000004704 * (TC + 273.15)**2))
    return sol
