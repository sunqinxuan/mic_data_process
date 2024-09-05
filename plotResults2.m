function plotResults2(x_m,y_m,z_m,x_hat,y_hat,z_hat,mag_earth_intensity)

fontsize=20;
x_m=x_m/mag_earth_intensity;
y_m=y_m/mag_earth_intensity;
z_m=z_m/mag_earth_intensity;
x_hat=x_hat/mag_earth_intensity;
y_hat=y_hat/mag_earth_intensity;
z_hat=z_hat/mag_earth_intensity;
mag_earth_intensity=1;
% figure;
% Visualization %
% Sensor readings and ellipoid fit
scatter3(x_m, y_m, z_m, 'fill', 'MarkerFaceColor', 'red'); hold on; 
% v = ellipsoid_fit(x_m, y_m, z_m);
% plot_ellipsoid(v,'g'); 
% title({'Before magnetometer calibration', '(Ellipsoid fit)'});
% xlabel('X-axis'); ylabel('Y-axis'); zlabel('Z-axis');
% axis equal;

% After calibrations
% figure;
scatter3(x_hat, y_hat, z_hat, 'fill', 'MarkerFaceColor', 'blue'); hold on;
% v2 = ellipsoid_fit(x_hat, y_hat, z_hat);
% plot_ellipsoid(v2,'b'); 
plot_sphere([0,0,0]', mag_earth_intensity);
% title({'After magnetometer calibration', '(Normalized to unit sphere)'});
xlabel('X','FontSize',fontsize); 
ylabel('Y','FontSize',fontsize); 
zlabel('Z','FontSize',fontsize);
axis equal;
% legend('earth magnetic field: IGRF data','after compensation: calibrated data','sphere');

set(gca,'FontSize',fontsize);


