clc
clear
close all

addpath('.\src')
addpath('.\data')
addpath('.\m_IGRF')

% folder='.\data\Flight8_0909\model_square\';
% load_file_name='.\data\Flight8_0909\model_square\Flight8_0909.txt';

folder='.\data\Flight1_0814\model_ellipsoid\';
load_file_name='.\data\Flight1_0814\model_ellipsoid\Flight1_0814.txt';

%% 

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
    R_nb=R_NE*euler2dcm(ins_roll(k),ins_pitch(k),ins_yaw(k),'ZXY');
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

matrix=R_opt'*D_tilde_inv;
offset=o_hat;
[x_hat,y_hat,z_hat,res_m3,res_hat3]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset);
subplot(1,2,2);
plotResults2(x_b,y_b,z_b,x_hat,y_hat,z_hat,mag_earth_intensity);
legend('地磁场矢量方向','补偿磁场矢量方向','单位球面', 'FontSize', fontsize);

%%
% figure;
% 
% matrix=D_tilde_inv;
% offset=o_hat;
% [x_hat,y_hat,z_hat,res_m2,res_hat2]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset);
% subplot(1,2,1);
% plotResults(x_b,y_b,z_b,x_hat,y_hat,z_hat,mag_earth_intensity);
% 
% matrix=R_hat'*D_tilde_inv;
% offset=o_hat;
% [x_hat1,y_hat1,z_hat1,res_m2,res_hat2]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset);
% subplot(1,2,2);
% plotResults(x_b,y_b,z_b,x_hat1,y_hat1,z_hat1,mag_earth_intensity);

%%
% figure('Position',[100,100,1000,600]);
% 
% fontsize=20;
% plot(tt,res_m3,'r'); hold on;
% plot(tt,res_hat3,'b'); hold on;
% grid on;
% xlabel('时间[s]','FontSize',fontsize); 
% ylabel('磁场强度[nT]','FontSize',fontsize); 
% set(gca,'FontSize',fontsize);
% legend('测量误差','补偿误差', 'FontSize', fontsize);

%% 

delta_x=-(x_b-x_m);
delta_y=(y_b-y_m);
delta_z=-(z_b-z_m);
% delta_m=(mag_truth_body(:,4)-mag_measure_body(:,4));

rmse_x=abs(mean(delta_x))
rmse_y=abs(mean(delta_y))
rmse_z=abs(mean(delta_z))
rmse_mag=sqrt(abs(mean(res_m3.*res_m3)))

delta_x_c=(x_b-x_hat);
delta_y_c=(y_b-y_hat);
delta_z_c=(z_b-z_hat);
% delta_m_c=(mag_truth_body(:,4)-mag_comp_body(:,4));

rmse_x_comp=abs(mean(delta_x_c))
rmse_y_comp=abs(mean(delta_y_c))
rmse_z_comp=abs(mean(delta_z_c))
rmse_mag_comp=sqrt(abs(mean(res_hat3.*res_hat3)))
% rmse_mag_comp=abs(mean(res_hat3))

scale=1;
delta_x_c(delta_x_c > 1000) = 0;
delta_y_c(delta_y_c > 1000) = 0;
delta_z_c(delta_z_c > 1000) = 0;
res_m3(res_hat3 > 1000) = 0;
delta_x_c(delta_x_c < -1000) = 0;
delta_y_c(delta_y_c < -1000) = 0;
delta_z_c(delta_z_c < -1000) = 0;
res_m3(res_hat3 < -1000) = 0;

figure('WindowState', 'maximized');
fontsize=20;

subplot(2,2,1);
plot(tt,delta_x,'-','DisplayName','测量误差','LineWidth',1); hold on;
plot(tt,delta_x_c*scale,'-','DisplayName','补偿误差','LineWidth',1); hold on;
ylabel('X轴分量/nT', 'FontSize', fontsize);
set(gca,'FontSize',fontsize);
legend('FontSize', fontsize);
grid on;

subplot(2,2,2);
plot(tt,delta_y,'-','DisplayName','测量误差','LineWidth',1); hold on;
plot(tt,delta_y_c*scale,'-','DisplayName','补偿误差','LineWidth',1); hold on;
ylabel('Y轴分量/nT', 'FontSize', fontsize);
set(gca,'FontSize',fontsize);
legend;
grid on;

subplot(2,2,3);
plot(tt,delta_z,'-','DisplayName','测量误差','LineWidth',1); hold on;
plot(tt,delta_z_c*scale,'-','DisplayName','补偿误差','LineWidth',1); hold on;
ylabel('Z轴分量/nT', 'FontSize', fontsize);
set(gca,'FontSize',fontsize);
legend;
grid on;

subplot(2,2,4);
plot(tt,res_m3,'-','DisplayName','测量误差','LineWidth',1); hold on;
plot(tt,res_hat3*scale,'-','DisplayName','补偿误差','LineWidth',1); hold on;
ylabel('磁场强度/nT', 'FontSize', fontsize);
set(gca,'FontSize',fontsize);
legend;
grid on;




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

