clear all; clc; close all;

archivo = "C:\Users\javil\Desktop\TFM\BatimetriaSanSimon\bathymetry_SanSimon_Bat.nc";

lon = ncread(archivo, 'lon');
lat = ncread(archivo, 'lat');
z = ncread(archivo, 'z') - 1.772;

z(z == 9999) = NaN;

%Corrección de altura con respecto nivel 0.
z = z - 1.772;

figure('Color','w')

surf(lon, lat, z, z, ...
    'EdgeColor','none', ...
    'FaceColor','interp');

shading interp
colormap(turbo)
cb = colorbar;
ylabel(cb,'Cota / batimetría (m)')

xlabel('Longitud')
ylabel('Latitud')
zlabel('Batimetría (m)')

title('Mapa 3D de batimetría - Ensenada de San Simón') #MF: ¿cómo te queda? 


view(45, 35)

%Iluminación para relieve
camlight headlight
lighting gouraud
material dull


axis tight
grid on
box on

%Exageración vertical visual
pbaspect([1 1 0.25])
