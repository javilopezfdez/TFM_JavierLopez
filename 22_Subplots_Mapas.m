clear; clc; close all;

%% =========================
% CARPETA PYTHON
%% =========================
output_dir = "C:\Users\javil\Desktop\TFM\FIGURAS\importantes\SeriesTemporales";

%% =========================
% ARCHIVOS
%% =========================
archivos = containers.Map;
archivos('SS5') = 'C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\Agrupar\SS5_FLUJOS_BAT_VIENTOS.xlsx';
archivos('SS6') = 'C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\Agrupar\SS6_FLUJOS_BAT_VIENTOS.xlsx';
archivos('SS7') = 'C:\Users\javil\Desktop\TFM\excel\MUY_AVANZADOS\Agrupar\SS7_FLUJOS_BAT_VIENTOS.xlsx';

orden_salidas = {'SS5','SS6','SS7'};

fechas_titulo = containers.Map;
fechas_titulo('SS5') = '6^t^h April 2026';
fechas_titulo('SS6') = '23^r^d April 2026';
fechas_titulo('SS7') = '12^t^h May 2026';

%% ---- Ticks del mapa solo en minutos, 3 valores para que no se junten ----
lon_ticks = -(8 + [40 38 36] / 60);
lon_labels = {'40''', '38''', '36'''};

lat_ticks = 42 + [17 19 21] / 60;
lat_labels = {'17''', '19''', '21'''};
%% ---- Dominio mapa ----
lat_min = 42.275;
lat_max = 42.3555;
lon_min = -8.68;
lon_max = -8.59;
%% =========================
% LOOP PRINCIPAL
%% =========================
for j = 1:numel(orden_salidas)

    salida = orden_salidas{j};
    archivo = archivos(salida);
    fecha_actual = fechas_titulo(salida);

    datos = readtable(archivo, 'VariableNamingRule','preserve');
    datos.Properties.VariableNames = strtrim(datos.Properties.VariableNames);

    lon = datos.lon;
    lat = datos.lat;

    sst = datos.sst;
    sss = datos.sss;
    sso = datos.sso;
    pCO2 = datos.pCO2_ajustada;

    if ismember('pCO2_discreto', datos.Properties.VariableNames)
        pCO2_discreto = datos.pCO2_discreto;
    else
        pCO2_discreto = nan(height(datos),1);
    end

    %% =========================
    % FIGURA FINAL
    %% =========================
    fig = figure('Position',[100 100 1400 900]);
    tiledlayout(2,4,'TileSpacing','compact','Padding','compact');

    %% =========================
    % 1) SERIE TEMPORAL (ARRIBA)
    %% =========================
    nexttile([1 4])

    img_path = fullfile(output_dir, salida + ".png");

    if exist(img_path,'file')
        imshow(imread(img_path))
    else
        text(0.5,0.5,"Missing Python image",'HorizontalAlignment','center')
        axis off
    end

    

    %% =========================
    % 2) MAPAS (ABAJO)
    %% =========================

    variables = {
        sst,  'Sea Surface Temperature (ºC)',              cmocean('thermal');
        sss,  'Sea Surface Salinity',                  cmocean('haline');
        sso,  'Sea Surface Oxygen (mg/L)',            cool;
        pCO2, 'Sea Surface pCO2 (\muatm)',        parula(256)
    };

    for i = 1:4
        nexttile

        var = variables{i,1};
        cmap = variables{i,3};
        titulo = variables{i, 2};
        media = mean(var(:), 'omitnan');
        sd = std(var(:), 'omitnan');

        m_proj('miller', ...
            'lon', [lon_min lon_max], ...
            'lat', [lat_min lat_max]);

        hold on
        hold on;

        m_scatter(lon, lat, 42, var, 'filled');

        if contains(titulo, 'pCO2')
            idx_disc = ~isnan(pCO2_discreto) & ~isnan(lon) & ~isnan(lat);

            m_scatter(lon(idx_disc), lat(idx_disc), 120, ...
                'o', ...
                'MarkerEdgeColor', 'k', ...
                'MarkerFaceColor', 'none', ...
                'LineWidth', 1.0);
        end
        m_gshhs_f('patch',[0.7 0.7 0.7])

        m_grid( ...
    'box', 'fancy', ...
    'tickdir', 'in', ...
    'xtick', lon_ticks, ...
    'ytick', lat_ticks, ...
    'xticklabels', [], ...
    'yticklabels', [] ...
);

for kk = 1:numel(lon_ticks)
    m_text(lon_ticks(kk), lat_min - 0.003, lon_labels{kk}, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'FontSize', 8);
end

for kk = 1:numel(lat_ticks)
    m_text(lon_min - 0.004, lat_ticks(kk), lat_labels{kk}, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 8);
end

        colormap(gca,cmap)
        colorbar

        title(variables{i,2})
        hold off
    end

    sgtitle("Obtained on " + fecha_actual, ...
        'FontWeight','bold', ...
        'FontSize',14);

    %% =========================
    % EXPORTAR
    %% =========================
    exportgraphics(fig, ...
        fullfile(output_dir, salida + "_FIGURA_FINAL.png"), ...
        "Resolution",1200)

end
