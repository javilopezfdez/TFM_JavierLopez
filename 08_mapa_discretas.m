%-----------DISCRETAS------------
T = readtable("C:\Users\javil\Desktop\TFM\excel\SS6_discrete_samples.xlsx"); %EXCEL de medidas discretas.

% Extraer variables como arrays
latd = T.lat;
lond = T.lon;
pCO2d = T.pCO2;

% ---- Dominio ----
lat_min = 42.273;
lat_max = 42.375;
lon_min = -8.7;
lon_max = -8.5676;

%-------Se realiza la figura--------
figure
m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]);
hold on

% Representación de medidas discretas
m_scatter(lond, latd, 100, pCO2d, 'filled');


offset_lon = 0.0035;   %Ajuste posicional del cuadro de texto con el valor
for i = 1:length(lond)
    texto = sprintf('%.0f', pCO2d(i));

    m_text(lond(i) + offset_lon, latd(i), texto, ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'middle', ...
        'BackgroundColor', 'white', ...
        'EdgeColor', 'black', ...   %
        'Margin', 2, ...
        'FontSize', 9, ...
        'Color', 'black');
end

colormap(turbo);
colorbar;

% Costa
m_gshhs_f('patch',[0.7 0.7 0.7]);

% Grilla
m_grid('box','fancy','tickdir','in');

title('Medidas discretas de pCO2 (µatm) – 23/04/2026','fontsize',14)
