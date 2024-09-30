clc
clear
close all

addpath('.\src')
addpath('.\data')
addpath('.\m_IGRF')

folder='.\data\UAV5\';
load_file_name=[folder,'uav5_flight12_0915.txt'];


%% read Mag13 data

% 第X1,Y1,Z1列为舱外，第X2,Y2,Z2,列为舱内
% T1,X1,Y1,Z1,TotalFieldStrength1,X2,Y2,Z2,TotalFieldStrength2

fileID = fopen(load_file_name, 'r');
data = textscan(fileID, '%s %f %f %f %f %f %f %f %f', 'Delimiter', ',');
fclose(fileID);

tt_str = data{1};
timestamp = datetime(tt_str, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
[h,m,s] = hms(timestamp);
tt= h.*3600+m.*60+s;

x_n=data{2};
y_n=data{3};
z_n=data{4};
mag_n=data{5};

x_m=data{6};
y_m=data{7};
z_m=data{8};
mag_m=data{9};

x_b=x_n;
y_b=y_n;
z_b=z_n;

mag_earth_intensity=mean(mag_n);

% data_ins=[timestamp,ins_pitch,ins_roll,ins_yaw];

%%  load model 

D_tilde_inv=load([folder,'D_tilde_inv.txt']);
o_hat=load([folder,'o_hat.txt']);
R_hat=load([folder,'R_hat.txt']);
R_opt=load([folder,'R_opt.txt']);


%%
figure('WindowState', 'maximized');

fontsize=40;

matrix=eye(3);
offset=zeros(3,1);
[x_hat,y_hat,z_hat,res_m,res_hat]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset);
subplot(1,2,1);
plotResults2(x_b,y_b,z_b,x_hat,y_hat,z_hat,mag_earth_intensity);
legend('舱外磁场矢量方向','测量磁场矢量方向','单位球面', 'FontSize', fontsize);

matrix=R_opt'*D_tilde_inv;
offset=o_hat;
[x_hat,y_hat,z_hat,res_m3,res_hat3]=applyModel(x_m,y_m,z_m,mag_earth_intensity,matrix,offset);
subplot(1,2,2);
plotResults2(x_b,y_b,z_b,x_hat,y_hat,z_hat,mag_earth_intensity);
legend('舱外磁场矢量方向','补偿磁场矢量方向','单位球面', 'FontSize', fontsize);


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
% delta_x_c(delta_x_c > 1000) = 0;
% delta_y_c(delta_y_c > 1000) = 0;
% delta_z_c(delta_z_c > 1000) = 0;
% res_m3(res_hat3 > 1000) = 0;
% delta_x_c(delta_x_c < -1000) = 0;
% delta_y_c(delta_y_c < -1000) = 0;
% delta_z_c(delta_z_c < -1000) = 0;
% res_m3(res_hat3 < -1000) = 0;

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

%% save data

save_file_name=[load_file_name,'_out.txt'];
fileID = fopen(save_file_name, 'w');
if fileID == -1
    error('cannot open file!');
end
for j=1:size(tt_str,1)
    h=norm([x_hat(j),y_hat(j),z_hat(j)]);    
    fprintf(fileID,'%s,%f,%f,%f,%f\n', ...
        cell2mat(tt_str(j)),x_hat(j),y_hat(j),z_hat(j),h);
end
fclose(fileID);


%% save data

% save_file_name=[load_file_name,'_data.txt'];
% fileID = fopen(save_file_name, 'w');
% if fileID == -1
%     error('cannot open file!');
% end
% for j=1:size(tt,1)
%     fprintf(fileID,'%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', ...
%         tt(j),mag_m(j),x_m(j),y_m(j),z_m(j),...
%         mag_n(j),x_n(j),y_n(j),z_n(j),...
%         0,0,0);
% end
% fclose(fileID);
