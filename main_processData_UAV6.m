clc
clear
close all

addpath('.\src')
addpath('.\data')
addpath('.\m_IGRF')

folder='.\data\UAV6\';
load_file_name=[folder,'uav6_flight14_0916_measure.txt'];
load_file_name2=[folder,'uav6_flight14_0916_truth.txt'];

%% read Mag13 data

fileID = fopen(load_file_name, 'r');
data = textscan(fileID, '%s %f %f %f %f', 'Delimiter', ',');
fclose(fileID);

tt_str_m = data{1};
timestamp = datetime(tt_str_m, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
[h,m,s] = hms(timestamp);
tt_m= h.*3600+m.*60+s;

x_m=data{2};
y_m=data{3};
z_m=data{4};
mag_m=data{5};

fileID = fopen(load_file_name2, 'r');
data = textscan(fileID, '%s %f %f %f %f', 'Delimiter', ',');
fclose(fileID);

tt_str_n = data{1};
timestamp = datetime(tt_str_n, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
[h,m,s] = hms(timestamp);
tt_n= h.*3600+m.*60+s;

x_n=data{2};
y_n=data{3};
z_n=data{4};
mag_n=data{5};

mag_earth_intensity=mean(mag_n);

%%
% figure;
% plot(x_n,'r');hold on;
% plot(x_m,'b');

%% time synchronization

x_n_sync=x_m;
y_n_sync=y_m;
z_n_sync=z_m;
mag_n_sync=mag_m;

for i=1:size(tt_m,1)
    [~, idx] = min(abs(tt_n - tt_m(i)));
    x_n_sync(i)=x_n(idx);
    y_n_sync(i)=y_n(idx);
    z_n_sync(i)=z_n(idx);
    mag_n_sync(i)=mag_n(idx);
    if mod(i,100)==0
        disp(i);
    end
end

x_n=x_n_sync;
y_n=y_n_sync;
z_n=z_n_sync;
mag_n=mag_n_sync;

%%
x_b=x_n;
y_b=y_n;
z_b=z_n;

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

tt=tt_m;

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
for j=1:size(tt_str_m,1)
    h=norm([x_hat(j),y_hat(j),z_hat(j)]);    
    fprintf(fileID,'%s,%f,%f,%f,%f\n', ...
        cell2mat(tt_str_m(j)),x_hat(j),y_hat(j),z_hat(j),h);
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
