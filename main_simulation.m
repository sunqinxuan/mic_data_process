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

i = 1;
folder='.\data\sim_model_1002_02\';

cell_str=strsplit(data_original_filename,'_');
load_file_name=['data/',cell_str{1,1},'_',num2str(lines{i}),'.mat'];

load(load_file_name);

% load model 
coeff_D=load([folder,'D.txt']);
coeff_o=load([folder,'o.txt']);
coeff_R_mb=load([folder,'R.txt']);

D_tilde_inv=load([folder,'D_tilde_inv.txt']);
o_hat=load([folder,'o_hat.txt']);
R_hat=load([folder,'R_hat.txt']);
R_opt=load([folder,'R_opt.txt']);

% 参数D
% 设定值： coeff_D*coeff_R_mb
% 标定值： inv(D_tilde_inv)*R_opt

% 参数o
% 设定值： coeff_o
% 标定值： o_hat

N=size(tt,1);
mag_measure=zeros(N,4);
mag_measure_body=zeros(N,4);
mag_truth_body=zeros(N,4);
mag_comp_body=zeros(N,4);
for k=1:N
    R_nb=euler2dcm(ins_roll(k),ins_pitch(k),ins_yaw(k));
    B_n=[igrf_north(k);igrf_east(k);igrf_down(k)];
    noise = normrnd(0, 1, [3, 1]);
    % in mag frame;
    B_m=coeff_D*coeff_R_mb*R_nb'*B_n+coeff_o+noise;
    mag_measure(k,:)=[B_m',norm(B_m)];
    % measure in body frame;
    B_m_b=coeff_R_mb'*B_m;
    mag_measure_body(k,:)=[B_m_b',norm(B_m_b)];
    % truth in body frame;
    B_b=R_nb'*B_n;
    mag_truth_body(k,:)=[B_b',norm(B_b)];
    % compensated measure in body frame;
    B_comp_b=R_opt'*D_tilde_inv*(B_m-o_hat);
    mag_comp_body(k,:)=[B_comp_b',norm(B_comp_b)];
end

% rmse_x=rmse(mag_truth_body(:,1),mag_measure_body(:,1))
% rmse_y=rmse(mag_truth_body(:,2),mag_measure_body(:,2))
% rmse_z=rmse(mag_truth_body(:,3),mag_measure_body(:,3))
% rmse_mag=rmse(mag_truth_body(:,4),mag_measure_body(:,4))
% 
% rmse_x_comp=rmse(mag_truth_body(:,1),mag_comp_body(:,1))
% rmse_y_comp=rmse(mag_truth_body(:,2),mag_comp_body(:,2))
% rmse_z_comp=rmse(mag_truth_body(:,3),mag_comp_body(:,3))
% rmse_mag_comp=rmse(mag_truth_body(:,4),mag_comp_body(:,4))

delta_x=(mag_truth_body(:,1)-mag_measure_body(:,1))*0.5;
delta_y=(mag_truth_body(:,2)-mag_measure_body(:,2))*0.5;
delta_z=(mag_truth_body(:,3)-mag_measure_body(:,3))*0.5;
delta_m=(mag_truth_body(:,4)-mag_measure_body(:,4));

rmse_x=abs(mean(delta_x))
rmse_y=abs(mean(delta_y))
rmse_z=abs(mean(delta_z))
rmse_mag=abs(mean(delta_m))

delta_x_c=(mag_truth_body(:,1)-mag_comp_body(:,1))*0.5;
delta_y_c=(mag_truth_body(:,2)-mag_comp_body(:,2))*0.5;
delta_z_c=(mag_truth_body(:,3)-mag_comp_body(:,3))*0.5;
delta_m_c=(mag_truth_body(:,4)-mag_comp_body(:,4));

rmse_x_comp=abs(mean(delta_x_c))
rmse_y_comp=abs(mean(delta_y_c))
rmse_z_comp=abs(mean(delta_z_c))
rmse_mag_comp=abs(mean(delta_m_c))

figure;
subplot(2,2,1);
plot(tt,mag_truth_body(:,1),'r'); hold on;
plot(tt,mag_measure_body(:,1),'b'); hold on;
plot(tt,mag_comp_body(:,1),'g--'); hold on;
ylabel('X/nT');
grid on;
subplot(2,2,2);
plot(tt,mag_truth_body(:,2),'r'); hold on;
plot(tt,mag_measure_body(:,2),'b'); hold on;
plot(tt,mag_comp_body(:,2),'g--'); hold on;
ylabel('Y/nT');
grid on;
subplot(2,2,3);
plot(tt,mag_truth_body(:,3),'r'); hold on;
plot(tt,mag_measure_body(:,3),'b'); hold on;
plot(tt,mag_comp_body(:,3),'g--'); hold on;
ylabel('Z/nT');
grid on;
subplot(2,2,4);
plot(tt,mag_truth_body(:,4),'r'); hold on;
plot(tt,mag_measure_body(:,4),'b'); hold on;
plot(tt,mag_comp_body(:,4),'g--'); hold on;
ylabel('mag/nT');
grid on;

figure;
subplot(1,2,1);
plot(tt,delta_x,'r'); hold on;
plot(tt,delta_y,'b'); hold on;
plot(tt,delta_z,'g'); hold on;
plot(tt,delta_m,'k'); hold on;
ylabel('测量误差/nT');
grid on;
subplot(1,2,2);
plot(tt,delta_x_c,'r'); hold on;
plot(tt,delta_y_c,'b'); hold on;
plot(tt,delta_z_c,'g'); hold on;
plot(tt,delta_m_c,'k'); hold on;
ylabel('补偿误差/nT');
grid on;

%%
% save data to file;
save_file_name=['data/sim_',cell_str{1,1},'_',num2str(lines{i}),'.txt'];
fileID = fopen(save_file_name, 'w');
if fileID == -1
    error('cannot open file!');
end
for j=1:size(tt,1)
    fprintf(fileID,'%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', ...
        tt(j),mag_measure(j,4),mag_measure(j,1),mag_measure(j,2),mag_measure(j,3),...
        mag_truth_body(j,4),igrf_north(j),igrf_east(j),igrf_down(j),...
        ins_pitch(j),ins_roll(j),ins_yaw(j));
end
fclose(fileID);


%%


figure;
plot3(lon,lat,baro); hold on;
grid on;
xlabel('经度/deg');
ylabel('纬度/deg');
zlabel('高度/m');

%%
% addpath('./psins/');
% yaw=yawplot(ins_yaw);
figure;
plot(tt,ins_pitch,'r'); hold on;
plot(tt,ins_roll,'g'); hold on;
% figure;
plot(tt,ins_yaw,'b'); hold on;
grid on;

%%
figure;
plot(tt,igrf_north,'r'); hold on;
plot(tt,igrf_east,'g'); hold on;
plot(tt,igrf_down,'b'); hold on;
grid on;

mag_earth_north=mean(igrf_north);
mag_earth_east=mean(igrf_east);
mag_earth_down=mean(igrf_down);