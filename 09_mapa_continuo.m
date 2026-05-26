clear; clc; close all;

% ---- Leer archivo Excel ----
archivo = "C:\Users\javil\Desktop\TFM\excel\SanSimon_6_CONT_DISC.xlsx";
datos = readtable(archivo);


lon = datos.longitud;
lat = datos.latitud;
sst = datos.sst;
sal = datos.sss;
pCO2 = datos.pCO2_ajustada;
O2 = datos.sso;
cla = datos.cla;

%-----------------------ESTABLECER VARIABLE DE PLOT------------------------
var = pCO2; %Se cambia aquí para representar cualquier otra variable. Cambiar el título en función de la variable.
%--------------------------------------------------------------------------

min = min(var);
max = max(var);
%MF comment: OJO! min = min(var) y max = max(var) sobreescriben las funciones propias de MATLAB. 
% Cualquier llamada posterior a min() o max() dentro del script fallará. Puedes usar nombres como vmin, vmax, etc


% ---- Crear grilla ----
lon_unique = unique(lon);
lat_unique = unique(lat);

[Lon, Lat] = meshgrid(lon_unique, lat_unique);
SST_grid = griddata(lon, lat, sst, Lon, Lat);
sss_grid = griddata(lon,lat,sal,Lon,Lat);
pCO2_grid = griddata(lon,lat,pCO2,Lon,Lat);

var_grid=griddata(lon,lat,var,Lon,Lat);

% ---- Dominio ----
lat_min = 42.273;
lat_max = 42.375;
lon_min = -8.7;
lon_max = -8.5676;

%-----Realizar el mapa-----
figure
m_proj('miller','lon',[lon_min lon_max], ...
                 'lat',[lat_min lat_max]);

hold on
caxis([min max]);
colorbar;
m_scatter(lon, lat, 36, var, 'filled'); %Mapa de puntos


% ---- Costa ----
m_gshhs_f('patch',[0.7 0.7 0.7]);

% ---- Grilla ----
m_grid('box','fancy','tickdir','in');

title('Distribución de pCO2 superficial del mar (µatm) el día 23/04/2026.','fontsize',14)
