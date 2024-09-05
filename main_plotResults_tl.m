clc
clear
close all

addpath('.\data')
addpath('.\m_IGRF')

model='tlc';
output_data_file='output_tlc.txt';

% data_original_filename = 'Flt1002_train.h5';
% time = datenum([2020 6 20]);
% lines={1002.02,1002.20};

data_original_filename = 'Flt1003_train.h5';
time = datenum([2020 6 29]); 
lines={1003.02,1003.04,1003.08};
i=1;

%% for i=1:size(lines,2)

% load data info
cell_str=strsplit(data_original_filename,'_');
% load_info_file_name=[cell_str{1,1},'_',num2str(lines{i}),'_info.txt'];
% fileID = fopen(load_info_file_name, 'r');
% mag_earth_intensity = fscanf(fileID, 'mag_earth_intensity = %f\n', 1);
% fclose(fileID);
% fprintf('mag_earth_intensity = %.6f\n', mag_earth_intensity);

% % load model 
% D_tilde_inv=load('D_tilde_inv.txt');
% o_hat=load('o_hat.txt');
% R_hat=load('R_hat.txt');
% R_opt=load('R_opt.txt');

% load data 
load_file_name=[cell_str{1,1},'_',num2str(lines{i}),'.txt'];
data=load(load_file_name);
mag_m=data(:,2);
x_m=data(:,3);
y_m=data(:,4);
z_m=data(:,5);

mag_n=data(:,6);
x_n=data(:,7);
y_n=data(:,8);
z_n=data(:,9);

ins_pitch=data(:,10);
ins_roll=data(:,11);
ins_yaw=data(:,12);

x_b = zeros(length(x_m),1); 
y_b = zeros(length(x_m),1); 
z_b = zeros(length(x_m),1);
for k=1:size(x_m,1)
    R_nb=euler2dcm(ins_roll(k),ins_pitch(k),ins_yaw(k));
    h_n=[x_n(k);y_n(k);z_n(k)];
    h_b=R_nb'*h_n;
    x_b(k)=h_b(1);
    y_b(k)=h_b(2);
    z_b(k)=h_b(3);
end

% mag_earth_intensity=mean(mag_n);
% fprintf('mag_earth_intensity = %.6f\n', mag_earth_intensity);

% % apply model
% matrix=R_hat'*D_tilde_inv;
% offset=o_hat;
% [x_hat,y_hat,z_hat]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset);

output_data=load(output_data_file);
mag_hat=output_data(:,2);
x_hat=output_data(:,3);
y_hat=output_data(:,4);
z_hat=output_data(:,5);

mag_hat_1=mag_hat;
mag_m_1=mag_m;
mag_n_1=mag_n;
for i=1:size(mag_hat,1)
    m=[x_hat(i);y_hat(i);z_hat(i)];
    mag_hat_1(i)=norm(m);
    m=[x_m(i);y_m(i);z_m(i)];
    mag_m_1(i)=norm(m);
    m=[x_n(i);y_n(i);z_n(i)];
    mag_n_1(i)=norm(m);
end

figure;

if strcmp(model,'tlc')
    fprintf('before calibration:'); 
    fprintf('\tRMSE_x ='); disp(rmse(x_n,x_m));
    fprintf('\tRMSE_y ='); disp(rmse(y_n,y_m));
    fprintf('\tRMSE_z ='); disp(rmse(z_n,z_m));
    fprintf('\tRMSE_intensity ='); disp(rmse(mag_n_1,mag_m_1));
    fprintf('after calibration:'); 
    fprintf('\tRMSE_x ='); disp(rmse(x_n,x_hat));
    fprintf('\tRMSE_y ='); disp(rmse(y_n,y_hat));
    fprintf('\tRMSE_z ='); disp(rmse(z_n,z_hat));
    fprintf('\tRMSE_intensity ='); disp(rmse(mag_n_1,mag_hat_1));

    % plotResults(x_m,y_m,z_m,x_hat,y_hat,z_hat,mag_earth_intensity);
    subplot(2,2,1);
    plot(x_m,'g'); hold on;
    plot(x_hat,'b'); hold on;
    plot(x_n,'r'); hold on;
    legend('before compensation','after compensation','groundtruth');
    title('mag-x');
    % plotResults2(x_b,y_b,z_b,x_hat,y_hat,z_hat,mag_earth_intensity);
    subplot(2,2,2);
    plot(y_m,'g'); hold on;
    plot(y_hat,'b'); hold on;
    plot(y_n,'r'); hold on;
    legend('before compensation','after compensation','groundtruth');
    title('mag-y');
    subplot(2,2,3);
    plot(z_m,'g'); hold on;
    plot(z_hat,'b'); hold on;
    plot(z_n,'r'); hold on;
    legend('before compensation','after compensation','groundtruth');
    title('mag-z');
    subplot(2,2,4);
    plot(mag_m_1,'g'); hold on;
    plot(mag_hat_1,'b'); hold on;
    plot(mag_n_1,'r'); hold on;
    legend('before compensation','after compensation','groundtruth');
    title('mag intensity');
end

if strcmp(model,'tl')
    plot(mag_m,'g'); hold on;
    plot(mag_hat,'b'); hold on;
    plot(mag_n,'r'); hold on;
    legen('before compensation','after compensation','groundtruth');
end
% % apply model
% matrix=R_opt'*D_tilde_inv;
% offset=o_hat;
% [x_hat,y_hat,z_hat]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset);
% plotResults(x_m,y_m,z_m,x_hat,y_hat,z_hat,mag_earth_intensity);
% plotResults2(x_b,y_b,z_b,x_hat,y_hat,z_hat,mag_earth_intensity);
% 
% % apply model
% matrix1=D_tilde_inv;
% offset1=o_hat;
% [x_hat1,y_hat1,z_hat1]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix1,offset1);
% plotResults2(x_b,y_b,z_b,x_hat1,y_hat1,z_hat1,mag_earth_intensity);

% % Print calibration params
% fprintf('3D magnetometer calibration based on ellipsoid fitting');
% fprintf('\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
% fprintf('\nThe calibration equation to be implemented:') 
% fprintf('\n\t\t\t\th_hat = matrix*(h_m - offset) \nWhere,')
% fprintf('\nh_m   = Measured sensor data vector');
% fprintf('\nh_hat = Calibrated sensor data vector');
% fprintf('\n\nmatrix =\n'); disp(matrix);
% fprintf('\noffset =\n'); disp(offset);

% end
