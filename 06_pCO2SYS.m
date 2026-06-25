
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

%MF comment: ¿tienes la función errors.m? Si es así, estaría bien que la usaras para calcular el error en pCO2. 
% dale un error al PAR1 de 2umolkg y un error al PAR2 de 0.0055 unidades de pH. Luego, calcula el error en pCO2 usando la función errors.m que usa unos argumentos de entrada muy muy similares a los de CO2SYS.
% Ese error podrías incluirlo luego como barras de error en la figura en la que comparas las medidas discretas contra las del sensor.