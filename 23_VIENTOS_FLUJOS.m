clear; clc; close all;

%% =========================
% CONFIGURACION
%% =========================
archivo = "C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\Agrupar\SS1_SS7_FLUJOS_BAT_VIENTOS_UNIDOS.xlsx";
salida_plot = "SS5";

lat_min = 42.275;
lat_max = 42.3555;
lon_min = -8.68;
lon_max = -8.59;

mapa_colores_v = "winter";
mapa_colores_f = "parula";

%% =========================
% DATOS
%% =========================
datos = readtable(archivo);

%% =========================
% FECHAS
%% =========================
fechas.SS1 = datetime(2024,10,24);
fechas.SS2 = datetime(2024,12,10);
fechas.SS3 = datetime(2025,2,6);
fechas.SS4 = datetime(2025,4,22);
fechas.SS5 = datetime(2026,4,6);
fechas.SS6 = datetime(2026,4,23);
fechas.SS7 = datetime(2026,5,12);

fecha_plot = fechas.(salida_plot);

%% =========================
% TICKS (MINUTOS)
%% =========================
lon_ticks = -(8 + [40 38 36] / 60);
lon_labels = {'40''','38''','36'''};

lat_ticks = 42 + [17 19 21] / 60;
lat_labels = {'17''','19''','21'''};

%% =========================
% FILTRO
%% =========================
datos = datos(string(datos.ID) == salida_plot, :);

lon = datos.lon;

lat = datos.lat;

viento_local = datos.ws;
viento_cop   = datos.w_cop;
viento_viso   = datos.viento_m_s;

fco2_local = datos.FCO2_molCm2yr;
fco2_cop   = datos.FCO2_cop;
fco2_viso   = datos.FCO2_viso;

%% =========================
% ESCALAS COMUNES
%% =========================
v = [viento_local; viento_cop; viento_viso];
f = [fco2_local; fco2_cop; fco2_viso];

cmin_v = mean(v,'omitnan') - 2*std(v,'omitnan');
cmax_v = mean(v,'omitnan') + 2*std(v,'omitnan');

cmin_f = mean(f,'omitnan') - 2*std(f,'omitnan');
cmax_f = mean(f,'omitnan') + 2*std(f,'omitnan');

%% =========================
% FIGURA
%% =========================
figure('Color','w','Position',[20 20 3300 1800]);

t = tiledlayout(3,2,'TileSpacing','compact','Padding','compact');

title_str = sprintf('Wind and FCO_2 Comparison - %s', string(fecha_plot,'dd/MM/yyyy'));
title(t, title_str, 'FontWeight','bold', 'FontSize', 14);

lat_offset = (lat_max - lat_min) * (-0.05);
lon_offset = (lon_max - lon_min) * (-0.05);

%% =========================
% 1 WIND LOCAL
%% =========================
nexttile
m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]);
hold on
m_scatter(lon,lat,40,viento_local,'filled')
colormap(gca,mapa_colores_v)
caxis([cmin_v cmax_v])
m_gshhs_f('patch',[0.7 0.7 0.7])
m_grid('box','fancy','tickdir','in', ...
       'xtick',lon_ticks,'ytick',lat_ticks, ...
       'xticklabels',[],'yticklabels',[]);
for k = 1:numel(lon_ticks)
    m_text(lon_ticks(k), lat_min + lat_offset, lon_labels{k}, ...
        'HorizontalAlignment','center','FontSize',8);
end
for k = 1:numel(lat_ticks)
    m_text(lon_min + lon_offset, lat_ticks(k), lat_labels{k}, ...
        'HorizontalAlignment','right','FontSize',8);
end
cb = colorbar;
cb.Location = 'eastoutside';
cb.Label.String = 'Wind speed (m/s)';
cb.FontSize = 8;
title('Wind Local','FontWeight','normal')

%% =========================
% 2 FCO2 LOCAL
%% =========================
nexttile
m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]);
hold on
m_scatter(lon,lat,40,fco2_local,'filled')
colormap(gca,mapa_colores_f)
caxis([cmin_f cmax_f])
m_gshhs_f('patch',[0.7 0.7 0.7])
m_grid('box','fancy','tickdir','in', ...
       'xtick',lon_ticks,'ytick',lat_ticks, ...
       'xticklabels',[],'yticklabels',[]);
for k = 1:numel(lon_ticks)
    m_text(lon_ticks(k), lat_min + lat_offset, lon_labels{k}, ...
        'HorizontalAlignment','center','FontSize',8);
end
for k = 1:numel(lat_ticks)
    m_text(lon_min + lon_offset, lat_ticks(k), lat_labels{k}, ...
        'HorizontalAlignment','right','FontSize',8);
end
cb = colorbar;
cb.Location = 'eastoutside';
cb.Label.String = 'FCO_2 (mol C m^{-2} yr^{-1})';
cb.FontSize = 8;
title('FCO_2 Local','FontWeight','normal')

%% =========================
% 3 WIND COPERNICUS
%% =========================
nexttile
m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]);
hold on
m_scatter(lon,lat,40,viento_cop,'filled')
colormap(gca,mapa_colores_v)
caxis([cmin_v cmax_v])
m_gshhs_f('patch',[0.7 0.7 0.7])
m_grid('box','fancy','tickdir','in', ...
       'xtick',lon_ticks,'ytick',lat_ticks, ...
       'xticklabels',[],'yticklabels',[]);
for k = 1:numel(lon_ticks)
    m_text(lon_ticks(k), lat_min + lat_offset, lon_labels{k}, ...
        'HorizontalAlignment','center','FontSize',8);
end
for k = 1:numel(lat_ticks)
    m_text(lon_min + lon_offset, lat_ticks(k), lat_labels{k}, ...
        'HorizontalAlignment','right','FontSize',8);
end
cb = colorbar;
cb.Location = 'eastoutside';
cb.Label.String = 'Wind speed (m/s)';
cb.FontSize = 8;
title('Wind Copernicus','FontWeight','normal')

%% =========================
% 4 FCO2 COPERNICUS
%% =========================
nexttile
m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]);
hold on
m_scatter(lon,lat,40,fco2_cop,'filled')
colormap(gca,mapa_colores_f)
caxis([cmin_f cmax_f])
m_gshhs_f('patch',[0.7 0.7 0.7])
m_grid('box','fancy','tickdir','in', ...
       'xtick',lon_ticks,'ytick',lat_ticks, ...
       'xticklabels',[],'yticklabels',[]);
for k = 1:numel(lon_ticks)
    m_text(lon_ticks(k), lat_min + lat_offset, lon_labels{k}, ...
        'HorizontalAlignment','center','FontSize',8);
end
for k = 1:numel(lat_ticks)
    m_text(lon_min + lon_offset, lat_ticks(k), lat_labels{k}, ...
        'HorizontalAlignment','right','FontSize',8);
end
cb = colorbar;
cb.Location = 'eastoutside';
cb.Label.String = 'FCO_2 (mol C m^{-2} yr^{-1})';
cb.FontSize = 8;
title('FCO_2 Copernicus','FontWeight','normal')

%% =========================
% 5 WIND VISO
%% =========================
nexttile
m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]);
hold on
m_scatter(lon,lat,40,viento_viso,'filled')
colormap(gca,mapa_colores_v)
caxis([cmin_v cmax_v])
m_gshhs_f('patch',[0.7 0.7 0.7])
m_grid('box','fancy','tickdir','in', ...
       'xtick',lon_ticks,'ytick',lat_ticks, ...
       'xticklabels',[],'yticklabels',[]);
for k = 1:numel(lon_ticks)
    m_text(lon_ticks(k), lat_min + lat_offset, lon_labels{k}, ...
        'HorizontalAlignment','center','FontSize',8);
end
for k = 1:numel(lat_ticks)
    m_text(lon_min + lon_offset, lat_ticks(k), lat_labels{k}, ...
        'HorizontalAlignment','right','FontSize',8);
end
cb = colorbar;
cb.Location = 'eastoutside';
cb.Label.String = 'Wind speed (m/s)';
cb.FontSize = 8;
title('Wind O Viso','FontWeight','normal')

%% =========================
% 6 FCO2 VISO
%% =========================
nexttile
m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]);
hold on
m_scatter(lon,lat,40,fco2_viso,'filled')
colormap(gca,mapa_colores_f)
caxis([cmin_f cmax_f])
m_gshhs_f('patch',[0.7 0.7 0.7])
m_grid('box','fancy','tickdir','in', ...
       'xtick',lon_ticks,'ytick',lat_ticks, ...
       'xticklabels',[],'yticklabels',[]);
for k = 1:numel(lon_ticks)
    m_text(lon_ticks(k), lat_min + lat_offset, lon_labels{k}, ...
        'HorizontalAlignment','center','FontSize',8);
end
for k = 1:numel(lat_ticks)
    m_text(lon_min + lon_offset, lat_ticks(k), lat_labels{k}, ...
        'HorizontalAlignment','right','FontSize',8);
end
cb = colorbar;
cb.Location = 'eastoutside';
cb.Label.String = 'FCO_2 (mol C m^{-2} yr^{-1})';
cb.FontSize = 8;
title('FCO_2 O Viso','FontWeight','normal')

