
clear; clc; close all;

T = readtable("C:\Users\javil\Desktop\TFM\excel\SS6_discrete_samples.xlsx");

%% TSPN CONDITIONS

PRESIN = 0;  % Presión (dbar)
PRESOUT = 0; % Presión (dbar)
SI = 0;       % Silicato (µmol/kg)
PO4 = 0;      % Fosfato (µmol/kg)
NH4 = 0;      % Amonio (µmol/kg)
H2S = 0;      % Sulhídrico (µmol/kg)
% Tipos de parámetros para CO2SYS 
PAR1TYPE = 1; % AT
PAR2TYPE = 3; % pH
AT      = T.ALKALI;
pH      = T.PH_TOT;
SAL     = T.sss;
TEMPIN  = 25; %Temperatura a la que se mide el pH en el laboratorio.
TEMPOUT = T.sst; %Temperatura del agua en el momento que se recoge la muestra.
% Escala de pH y constantes
pHSCALE = 1; % Total scale
K1K2    = 10;    % Lueker 
KSO4    = 1;     % Dickson para sulfato
KB= 2; % Lee 2010 
KF= 2; % Perez & Fraga, 1987
result=CO2SYS(AT(:),pH(:),PAR1TYPE,PAR2TYPE,...
SAL,TEMPIN2,TEMPOUT,PRESIN,PRESOUT,SI,PO4,NH4,H2S,pHSCALE,K1K2,KSO4,KF,KB);
pH_in = result(:,21); %pH calculado a la temperatura del agua en el momento del muestreo
pCO2 = result(:,22); %pCO2 calculado a partir del pH y alcalinidad
