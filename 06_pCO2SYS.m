clear; clc; close all;

T = readtable("C:\Users\javil\Desktop\TFM\excel\SS7_discrete_samples.xlsx");

%% =========================
% CONDICIONES CO2SYS
% =========================

PRESIN  = 0;   % dbar
PRESOUT = 0;   % dbar

SI  = 0;       % Silicato, µmol/kg
PO4 = 0;       % Fosfato, µmol/kg
NH4 = 0;       % Amonio, µmol/kg
H2S = 0;       % Sulhídrico, µmol/kg

% Tipos de parámetros
PAR1TYPE = 1;  % AT
PAR2TYPE = 3;  % pH

PAR1 = T.ALKALI(:);   % AT, µmol/kg
PAR2 = T.PH_TOT(:);   % pH total

SAL     = T.SAL(:);
TEMPIN  = 25;         % Temperatura del pH medido en laboratorio
TEMPOUT = T.sst(:);   % Temperatura in situ

% Escala de pH y constantes
pHSCALEIN       = 1;   % Total scale
K1K2CONSTANTS   = 10;  % Lueker
KSO4CONSTANT    = 1;   % Dickson
KFCONSTANT      = 2;   % Perez & Fraga, 1987
BORON           = 2;   % Lee 2010

%% =========================
% FILTRO DE DATOS VÁLIDOS
% =========================

idx = isfinite(PAR1) & isfinite(PAR2) & isfinite(SAL) & isfinite(TEMPOUT);

pH_in      = nan(height(T),1);
pCO2       = nan(height(T),1);
err_pCO2   = nan(height(T),1);

%% =========================
% CÁLCULO CO2SYS
% =========================

result = CO2SYS( ...
    PAR1(idx), PAR2(idx), PAR1TYPE, PAR2TYPE, ...
    SAL(idx), TEMPIN, TEMPOUT(idx), ...
    PRESIN, PRESOUT, SI, PO4, NH4, H2S, ...
    pHSCALEIN, K1K2CONSTANTS, KSO4CONSTANT, KFCONSTANT, BORON);

pH_in(idx) = result(:,21);   % pH calculado a temperatura in situ
pCO2(idx)  = result(:,22);   % pCO2 calculado a temperatura in situ

%% =========================
% ERRORES DE ENTRADA
% =========================

ePAR1 = 2;       % error AT, µmol/kg
ePAR2 = 0.0055;  % error pH, unidades de pH

% Si solo quieres propagar el error de AT y pH, pon el resto a 0
eSAL  = 0;
eTEMP = 0;
eSI   = 0;
ePO4  = 0;
eNH4  = 0;
eH2S  = 0;

% Errores de constantes y boro
% epK = 0 y eBt = 0 significa que NO incluyes incertidumbre de constantes
epK = 0;
eBt = 0;

% Correlación entre errores de AT y pH
% Normalmente 0 si son medidas independientes
r = 0;


[err, headers, units] = errors( ...
    PAR1(idx), PAR2(idx), PAR1TYPE, PAR2TYPE, ...
    SAL(idx), TEMPIN, TEMPOUT(idx), PRESIN, PRESOUT, SI, PO4, ...
    NH4, H2S, ePAR1, ePAR2, eSAL, eTEMP, eSI, ePO4, ...
    eNH4, eH2S, epK, eBt, r, pHSCALEIN, K1K2CONSTANTS, ...
    KSO4CONSTANT, KFCONSTANT, BORON);

err_pCO2(idx) = err(:,14);

%% =========================
% GUARDAR RESULTADOS EN LA TABLA
% =========================

T.pH_in_situ       = pH_in;
T.pCO2             = pCO2;
T.err_pCO2         = err_pCO2;
%% =========================
% GUARDAR EXCEL
% =========================

salida = "C:\Users\javil\Desktop\TFM\excel\SS7_discrete_samples_pCO2_error.xlsx";
writetable(T, salida);

disp("Archivo guardado en:");
disp(salida);
