clc
clear
close all

addpath('.\src')
addpath('.\data')
addpath('.\m_IGRF')

data_original_filename = 'Flt1002_train.h5';
time = datenum([2020 6 20]);
lines={1002.02,1002.20,1002.14,1002.16,1002.17};
output_data_file='output_Flt1002_1002.14.txt';
i=3;

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

mag_earth_intensity=mean(mag_n);
fprintf('mag_earth_intensity = %.6f\n', mag_earth_intensity);

% % apply model
% matrix=R_hat'*D_tilde_inv;
% offset=o_hat;
% [x_hat,y_hat,z_hat]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset);

output_data=load(output_data_file);
x_hat=output_data(:,3);
y_hat=output_data(:,4);
z_hat=output_data(:,5);

figure;
subplot(1,2,1);
plotResults(x_m,y_m,z_m,x_hat,y_hat,z_hat,mag_earth_intensity);
subplot(1,2,2);
plotResults2(x_b,y_b,z_b,x_hat,y_hat,z_hat,mag_earth_intensity);

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
