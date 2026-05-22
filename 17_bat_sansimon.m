clear all; clc; close all;

archivo = "C:\Users\javil\Desktop\TFM\BatimetriaSanSimon\bathymetry_SanSimon_Bat.nc";
salida = "C:\Users\javil\Desktop\TFM\excel\SS7_CON_VIENTOS.xlsx";

lon = ncread(archivo, 'lon');
lat = ncread(archivo, 'lat');
depth = ncread(archivo, 'z');
depth_1 = depth - 1.772;

% ---- Dominio ----
lat_min = 42.273;
lat_max = 42.375;
lon_min = -8.7;
lon_max = -8.5676;

%-------Se realiza la figura--------
figure
m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]);
hold on
m_pcolor(lon, lat, depth_1);
caxis([-25 0])
shading interp;
niveles = -50:10:10;
[C,h] = m_contour(lon, lat, depth_1, niveles, ...
    'Color',[0.15 0.15 0.15], 'LineWidth',0.7);

clabel(C,h,'FontSize',8,'Color',[0.15 0.15 0.15]);
%cmocean(deep);
colorbar;

% Costa
m_gshhs_f('patch',[0.7 0.7 0.7]);

% Grilla
m_grid('box','fancy','tickdir','in');

title('Batimetría de la ensenada de San Simón','fontsize',14)
