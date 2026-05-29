clear all; clc; close all;

% ---- Archivos ----
archivo_nc = "C:\Users\javil\Desktop\TFM\BatimetriaSanSimon\bathymetry_SanSimon_Bat.nc";
archivo_excel = "C:\Users\javil\Desktop\TFM\excel\SS4_CON_VIENTOS.xlsx";
salida_excel = "C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\SS4_FLUJOS_BAT.xlsx";

% ---- Leer batimetria ----
lon_bat = ncread(archivo_nc, 'lon');
lat_bat = ncread(archivo_nc, 'lat');
z_bat = ncread(archivo_nc, 'z');

z_bat(z_bat == 9999) = NaN;

% Si quieres aplicar la correccion vertical
z_bat = z_bat - 1.772;

% ---- Leer Excel ----
T = readtable(archivo_excel);

% ---- Coordenadas del Excel ----
lat_med = T.lat;
lon_med = T.lon;   % Cuidado con longitudes positivas y negativas. Y con los nombres lat y lon.

% ---- Preparar salida ----
batimetria_m = NaN(height(T),1);
lon_bat_cercana = NaN(height(T),1);
lat_bat_cercana = NaN(height(T),1);

% ---- Buscar batimetria punto por punto ----
for i = 1:height(T)

    lon0 = lon_med(i);
    lat0 = lat_med(i);

    dist2 = (lon_bat - lon0).^2 + (lat_bat - lat0).^2;

    % Ignorar celdas sin batimetria
    dist2(isnan(z_bat)) = NaN;

    [~, idx] = min(dist2(:), [], 'omitnan');

    batimetria_m(i) = z_bat(idx);
    lon_bat_cercana(i) = lon_bat(idx);
    lat_bat_cercana(i) = lat_bat(idx);

end

% ---- Añadir columnas al Excel ----
T.batimetria_m = batimetria_m;
T.lon_batimetria_cercana = lon_bat_cercana;
T.lat_batimetria_cercana = lat_bat_cercana;

% ---- Guardar nuevo Excel ----
writetable(T, salida_excel);

disp("Excel guardado en:")
disp(salida_excel)