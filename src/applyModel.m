function [x_hat,y_hat,z_hat,residual_h_m,residual_h_hat]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset)

residual_h_m=zeros(size(x_m));
residual_h_hat=zeros(size(x_m));

x_hat = zeros(length(x_m),1); 
y_hat = zeros(length(x_m),1); 
z_hat = zeros(length(x_m),1);

sum=0;
for i_iters = 1:length(x_m)
    % Sensor data
    h_m = [x_m(i_iters); y_m(i_iters); z_m(i_iters)]; 
    % Calibration, Eqn(11)
    h_hat = matrix*(h_m - offset);
    % Calibrated values
    x_hat(i_iters) = h_hat(1);
    y_hat(i_iters) = h_hat(2);
    z_hat(i_iters) = h_hat(3);
    % residuals
%     residual_h_m(i_iters)=abs(norm(h_m)-mag_earth_intensity);
%     residual_h_hat(i_iters)=abs(norm(h_hat)-mag_earth_intensity);
    sum=sum+norm(h_hat);
end
h_hat_mean=sum/length(x_m);

sum_m=0;
sum_hat=0;
for i=1:length(x_hat)
    h_m = [x_m(i); y_m(i); z_m(i)]; 
    h_hat = [x_hat(i); y_hat(i); z_hat(i)]; 
    residual_h_m(i)=(norm(h_m)-h_hat_mean)*1.0;%abs();
    residual_h_hat(i)=(norm(h_hat)-h_hat_mean)*1.0;%abs();
    sum_m=sum_m+residual_h_m(i)*residual_h_m(i);
    sum_hat=sum_hat+residual_h_hat(i)*residual_h_hat(i);
end

residual_h_m_mean=mean(residual_h_m);
residual_h_hat_mean=mean(residual_h_hat);

rmse_m=sqrt(sum_m/length(x_hat));
rmse_hat=sqrt(sum_hat/length(x_hat));

% fprintf('\nh_hat_mean ='); disp(h_hat_mean);
% fprintf('\nmag_earth_intensity ='); disp(mag_earth_intensity);
% 
% fprintf('\nresidual_h_m_mean ='); disp(residual_h_m_mean);
% fprintf('\nresidual_h_hat_mean ='); disp(residual_h_hat_mean);

fprintf('\nrmse_m ='); disp(rmse_m);
fprintf('\nrmse_hat ='); disp(rmse_hat);

% figure;
% plot(residual_h_m,'r'); hold on;
% plot(residual_h_hat,'b'); hold on;

