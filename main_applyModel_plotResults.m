clc
clear
close all

addpath('.\data')
addpath('.\m_IGRF')

data_original_filename = 'Flt1002_train.h5';
time = datenum([2020 6 20]);
lines={1002.02,1002.20,1002.14,1002.16,1002.17};

% data_original_filename = 'Flt1003_train.h5';
% time = datenum([2020 6 29]); 
% lines={1003.02,1003.04,1003.08};

% data_original_filename = 'Flt1006_train.h5';
% time = datenum([2020 7 6]); 
% lines={1006.04,1006.06,1006.08};

% data_original_filename = 'Flt1007_train.h5';
% time = datenum([2020 7 7]); 
% lines={1007.02,1007.06};

i = 4 ;
folder='.\data\model_1006_08\';


cell_str=strsplit(data_original_filename,'_');
load_info_file_name=[cell_str{1,1},'_',num2str(lines{i}),'_info.txt'];
load_file_name=[cell_str{1,1},'_',num2str(lines{i}),'.txt'];

% time_in=[2024 7 29];
% tt=datetime(time_in);
% time_str=datestr(tt,'yyyy-mm-dd');
% load_file_name=['data/data_',time_str,'.txt'];
% load_info_file_name=['data/data_',time_str,'_info.txt'];

%% for i=1:size(lines,2)
% i=1;

% load data info
% fileID = fopen(load_info_file_name, 'r');
% mag_earth_intensity = fscanf(fileID, 'mag_earth_intensity = %f\n', 1);
% fclose(fileID);
% fprintf('mag_earth_intensity = %.6f\n', mag_earth_intensity);

% load model 
D_tilde_inv=load([folder,'D_tilde_inv.txt']);
o_hat=load([folder,'o_hat.txt']);
R_hat=load([folder,'R_hat.txt']);
R_opt=load([folder,'R_opt.txt']);

% load data 
data=load(load_file_name);
tt=data(:,1);
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
R_NE= [0,1,0;1,0,0;0,0,-1]; % from ENU to NED;
s=pi/180.0;
for k=1:size(x_m,1)
    R_nb=euler2dcm(ins_roll(k),ins_pitch(k),ins_yaw(k));
%     R_bn=R_NE*angle2dcm(ins_yaw(k)*s,ins_pitch(k)*s,ins_roll(k)*s,'ZXY');
%     R_bn=angle2dcm(ins_yaw(k)*s,ins_pitch(k)*s,ins_roll(k)*s,'XZY');
    h_n=[x_n(k);y_n(k);z_n(k)];
    h_b=R_nb'*h_n;
%     h_b=R_bn*h_n;
%     h_b=h_n;
    x_b(k)=h_b(1);
    y_b(k)=h_b(2);
    z_b(k)=h_b(3);
end

mag_earth_intensity=mean(mag_n);
% fprintf('mag_earth_intensity = %.6f\n', mag_earth_intensity);

%%
figure('WindowState', 'maximized');

fontsize=40;

matrix=eye(3);
offset=zeros(3,1);
[x_hat,y_hat,z_hat,res_m,res_hat]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset);
subplot(1,2,1);
plotResults2(x_b,y_b,z_b,x_hat,y_hat,z_hat,mag_earth_intensity);
legend('地磁场矢量方向','测量磁场矢量方向','单位球面', 'FontSize', fontsize);

% matrix1=D_tilde_inv;
% offset1=o_hat;
% [x_hat1,y_hat1,z_hat1,res_m1,res_hat1]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix1,offset1);
% subplot(2,3,1);
% plotResults(x_m,y_m,z_m,x_hat1,y_hat1,z_hat1,mag_earth_intensity);
% subplot(2,3,4);
% plotResults2(x_b,y_b,z_b,x_hat1,y_hat1,z_hat1,mag_earth_intensity);

% matrix=R_hat'*D_tilde_inv;
% offset=o_hat;
% [x_hat,y_hat,z_hat,res_m2,res_hat2]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset);
% subplot(2,3,2);
% plotResults(x_m,y_m,z_m,x_hat,y_hat,z_hat,mag_earth_intensity);
% subplot(2,3,5);
% plotResults2(x_b,y_b,z_b,x_hat,y_hat,z_hat,mag_earth_intensity);

matrix=R_opt'*D_tilde_inv;
offset=o_hat;
[x_hat,y_hat,z_hat,res_m3,res_hat3]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset);
% subplot(2,3,3);
% plotResults(x_m,y_m,z_m,x_hat,y_hat,z_hat,mag_earth_intensity);
% subplot(2,3,6);
subplot(1,2,2);
plotResults2(x_b,y_b,z_b,x_hat,y_hat,z_hat,mag_earth_intensity);
legend('地磁场矢量方向','补偿磁场矢量方向','单位球面', 'FontSize', fontsize);

%%
figure('Position',[100,100,1000,600]);

fontsize=20;
% subplot(1,3,1);
% plot(res_m1,'r'); hold on;
% plot(res_hat1*0.2,'b'); hold on;
% subplot(1,3,2);
% plot(res_m2,'r'); hold on;
% plot(res_hat2*0.2,'b'); hold on;
% subplot(1,3,3);
plot(tt,res_m3,'r'); hold on;
plot(tt,res_hat3,'b'); hold on;
grid on;
xlabel('时间[s]','FontSize',fontsize); 
ylabel('磁场强度[nT]','FontSize',fontsize); 
set(gca,'FontSize',fontsize);
legend('测量误差','补偿误差', 'FontSize', fontsize);

%% Print calibration params
% fprintf('3D magnetometer calibration based on ellipsoid fitting');
% fprintf('\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
% fprintf('\nThe calibration equation to be implemented:') 
% fprintf('\n\t\t\t\th_hat = matrix*(h_m - offset) \nWhere,')
% fprintf('\nh_m   = Measured sensor data vector');
% fprintf('\nh_hat = Calibrated sensor data vector');
% fprintf('\n\nmatrix =\n'); disp(matrix);
% fprintf('\noffset =\n'); disp(offset);

% end

%%
% figure('WindowState', 'maximized');
% 
% matrix1=D_tilde_inv;
% offset1=o_hat;
% [x_hat1,y_hat1,z_hat1,res_m1,res_hat1]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix1,offset1);
% subplot(2,3,1);
% plotResults(x_m,y_m,z_m,x_hat1,y_hat1,z_hat1,mag_earth_intensity);
% subplot(2,3,4);
% plotResults2(x_b,y_b,z_b,x_hat1,y_hat1,z_hat1,mag_earth_intensity);
% 
% matrix=R_hat'*D_tilde_inv;
% offset=o_hat;
% [x_hat,y_hat,z_hat,res_m2,res_hat2]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset);
% subplot(2,3,2);
% plotResults(x_m,y_m,z_m,x_hat,y_hat,z_hat,mag_earth_intensity);
% subplot(2,3,5);
% plotResults2(x_b,y_b,z_b,x_hat,y_hat,z_hat,mag_earth_intensity);
% 
% matrix=R_opt'*D_tilde_inv;
% offset=o_hat;
% [x_hat,y_hat,z_hat,res_m3,res_hat3]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset);
% subplot(2,3,3);
% plotResults(x_m,y_m,z_m,x_hat,y_hat,z_hat,mag_earth_intensity);
% subplot(2,3,6);
% % subplot(1,2,2);
% plotResults2(x_b,y_b,z_b,x_hat,y_hat,z_hat,mag_earth_intensity);
% legend('地磁场矢量方向','补偿磁场矢量方向','单位球面', 'FontSize', fontsize);

