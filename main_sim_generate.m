clc
clear
close all

addpath('.\src')
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
folder='.\data\MIT\sim_model_1002_02\';

cell_str=strsplit(data_original_filename,'_');
load_file_name=['data/MIT/',cell_str{1,1},'_',num2str(lines{i}),'.mat'];

load(load_file_name);

% load model (user-set)
coeff_D=load([folder,'D.txt']);
coeff_o=load([folder,'o.txt']);
coeff_R_mb=load([folder,'R.txt']);

% load model (calibrated)
% D_tilde_inv=load([folder,'D_tilde_inv.txt']);
% o_hat=load([folder,'o_hat.txt']);
% R_hat=load([folder,'R_hat.txt']);
% R_opt=load([folder,'R_opt.txt']);

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
    R_nb=euler2dcm(ins_roll(k),ins_pitch(k),ins_yaw(k),'ZYX');
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
%     % compensated measure in body frame;
%     B_comp_b=R_opt'*D_tilde_inv*(B_m-o_hat);
%     mag_comp_body(k,:)=[B_comp_b',norm(B_comp_b)];
end

%% recording - generate simulated data

sim_generate_1002_02(tt,lon,lat,baro,mag_measure_body,mag_truth_body,ins_pitch,ins_roll,ins_yaw);

%%
% save simulated measurement data to file;
save_file_name=[folder,'sim_',cell_str{1,1},'_',num2str(lines{i}),'.txt'];
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

% figure;
% plot3(lon,lat,baro); hold on;
% grid on;
% xlabel('经度/deg');
% ylabel('纬度/deg');
% zlabel('高度/m');

%%

% figure;
% plot(tt,ins_pitch,'r'); hold on;
% plot(tt,ins_roll,'g'); hold on;
% plot(tt,ins_yaw,'b'); hold on;
% grid on;

%%
% figure;
% plot(tt,igrf_north,'r'); hold on;
% plot(tt,igrf_east,'g'); hold on;
% plot(tt,igrf_down,'b'); hold on;
% grid on;
% 
% mag_earth_north=mean(igrf_north);
% mag_earth_east=mean(igrf_east);
% mag_earth_down=mean(igrf_down);