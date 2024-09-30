clc
clear
close all

addpath('.\src')
addpath('.\data')
addpath('.\m_IGRF')

time = datenum([2024 8 14]); 

%% read mag13 data

data_csv=readData_csv('.\data\Flight1_0814\06_mag13\MAG13_DualChannel_data_20240814_122219.csv');

tt=table2array(data_csv(:,1));
[h,m,s] = hms(tt);
timestamp= h.*3600+m.*60+s;

x_m=table2array(data_csv(:,6));
y_m=table2array(data_csv(:,7));
z_m=table2array(data_csv(:,8));
mag=table2array(data_csv(:,9));

data_mag13_full=[timestamp,x_m,y_m,z_m,mag];

x_m=table2array(data_csv(:,2));
y_m=table2array(data_csv(:,3));
z_m=table2array(data_csv(:,4));
mag=table2array(data_csv(:,5));

data_mag13_truth_full=[timestamp,x_m,y_m,z_m,mag];

%% read INS data

% filename = '.\data\Flight1_0814\03_INS\INS_result_align0.5h_10hz_systime.txt';
% fileID = fopen(filename, 'r');
% data = textscan(fileID, '%s %s %f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
% fclose(fileID);
% 
% tt_str = data{1};
% tt = datetime(tt_str, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
% [h,m,s] = hms(tt);
% timestamp= h.*3600+m.*60+s;
% 
% ins_pitch=data{9}; % deg
% ins_roll=data{10};
% ins_yaw=data{11};
% 
% data_ins=[timestamp,ins_pitch,ins_roll,ins_yaw];

%% read GNSS data

% data_csv=readData_csv('.\data\Flight1_0814\10_GNSS\GNSS_20240814_100400_out.csv');
% 
% tt=table2array(data_csv(:,1));
% [h,m,s] = hms(tt);
% timestamp= h.*3600+m.*60+s;
% 
% lat=table2array(data_csv(:,2)); % deg
% lon=table2array(data_csv(:,3)); % deg
% alt=table2array(data_csv(:,4)); % m
% 
% data_gnss=[timestamp,lat,lon,alt];

%% read IGRF data

% dim_gnss=[size(data_gnss,1),1];
% mag_earth=zeros(dim_gnss);
% igrf_north=zeros(dim_gnss);
% igrf_east=zeros(dim_gnss);
% igrf_down=zeros(dim_gnss);
% gh = loadigrfcoefs(time);
% for j=1:size(data_gnss,1)
%     latitude=lat(j);
%     longitude=lon(j);
%     altitude=alt(j)*1e-3;
%     [Bx, By, Bz] = igrf(gh, latitude, longitude, altitude, 'geod');
%     mag_earth(j)=norm([Bx,By,Bz]);
%     igrf_north(j)=Bx;
%     igrf_east(j)=By;
%     igrf_down(j)=Bz;
% end
% mag_earth_intensity=mean(mag_earth);
% fprintf('mag_earth_intensity ='); disp(mag_earth_intensity);

%% 

% figure;
% plot(data_mag13(:,1),data_mag13(:,5),'DisplayName', 'mag13 intensity', 'LineWidth', 1); hold on;
% plot(data_ins(:,1),data_ins(:,4),'DisplayName', 'INS yaw', 'LineWidth', 1); hold on;
% plot(data_gnss(:,1),data_gnss(:,4),'DisplayName', 'GNSS altitude', 'LineWidth', 1); hold on;
% legend;

%% time synchronization

% tt_mag13=data_mag13(:,1);
% tt_ins=data_ins(:,1);
% tt_gnss=data_gnss(:,1);
% 
% data_mag13_sync=zeros(size(data_gnss,1),size(data_mag13,2));
% data_ins_sync=zeros(size(data_gnss,1),size(data_ins,2));
% 
% for i=1:size(data_gnss,1)
%     % mag13
%     [~, idx] = min(abs(tt_mag13 - tt_gnss(i)));
%     data_mag13_sync(i,:) = data_mag13(idx,:);
%     % ins
%     [~, idx] = min(abs(tt_ins - tt_gnss(i)));
%     data_ins_sync(i,:) = data_ins(idx,:);
%     if mod(i,100)==0
%         disp(i);
%     end
% end

%%

% save_file_name_mat='data/Flight1_0814/Flight1_0814.mat';
% save(save_file_name_mat,"data_gnss","data_mag13_sync","data_ins_sync","igrf_down","igrf_east","igrf_north","mag_earth");

%%

% clear;
% close all;
% clc;
% 
% load data\Flight1_0814\Flight1_0814.mat

% tt_gnss=data_gnss(:,1);
% 
% % 绘图展示对齐结果
% figure;
% hold on;
% 
% % 绘制10Hz数据
% plot(tt_gnss, data_gnss(:,4), '-', 'DisplayName', 'GNSS Data', 'LineWidth', 1);
% 
% % 绘制对齐后的20Hz数据
% plot(tt_gnss, data_ins_sync(:,4), '-', 'DisplayName', 'Sync INS Data', 'LineWidth', 1);
% 
% % 添加图例和标签
% legend show;
% xlabel('Time (s)');
% ylabel('Data Value');
% title('Syncronization of INS Data to GNSS Time Points');
% grid on;
% hold off;

%% 
% filename = '.\data\Flight1_0814\06_mag13\Flt1_mag13_calib.txt';
% fileID = fopen(filename, 'r');
% data = textscan(fileID, '%s %f %f %f %f %f %f %f %f', 'Delimiter', ',');
% fclose(fileID);
% 
% tt_str = data{1};
% tt = datetime(tt_str, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
% [h,m,s] = hms(tt);
% timestamp= h.*3600+m.*60+s;
% 
% mag_x=data{6}; % deg
% mag_y=data{7};
% mag_z=data{8};
% mag_t=data{9};
% 
% data_mag13_calib=[timestamp,mag_x,mag_y,mag_z,mag_t];
% 


%% data during the calibration flight (square flight)

% 17:03  高度3000m  61380
% 17:09  五边
% 17:21  结束五边   62460
t1=time2second(17,3,0);
t2=time2second(17,21,0);
r1=findIdx(timestamp,t1);
r2=findIdx(timestamp,t2);

range=r1:r2;

% data_gnss=data_gnss(range,:);
% data_ins_sync=data_ins_sync(range,:);
% data_mag13_sync=data_mag13_sync(range,:);
% igrf_down=igrf_down(range,:);
% igrf_east=igrf_east(range,:);
% igrf_north=igrf_north(range,:);
% mag_earth=mag_earth(range,:);

data_mag13=data_mag13_full(range,:);
data_mag13_truth=data_mag13_truth_full(range,:);

save_file_name_mat='data/Flight1_0814/Flight1_0814_cabin.mat';
save(save_file_name_mat,"data_mag13","data_mag13_truth");

%%

figure('WindowState', 'maximized');
timestamp=data_mag13(:,1);

subplot(2,2,1);
hold on;
plot(timestamp, data_mag13(:,2), '-', 'DisplayName', 'mag_x', 'LineWidth', 1);
plot(timestamp, data_mag13_truth(:,2), '-', 'DisplayName', 'truth_x', 'LineWidth', 1);
legend show;
xlabel('Time (s)');
ylabel('Data Value');
grid on;
hold off;

subplot(2,2,2);
hold on;
plot(timestamp, data_mag13(:,3), '-', 'DisplayName', 'mag_y', 'LineWidth', 1);
plot(timestamp, data_mag13_truth(:,3), '-', 'DisplayName', 'truth_y', 'LineWidth', 1);
legend show;
xlabel('Time (s)');
ylabel('Data Value');
grid on;
hold off;

subplot(2,2,3);
hold on;
plot(timestamp, data_mag13(:,4), '-', 'DisplayName', 'mag_z', 'LineWidth', 1);
plot(timestamp, data_mag13_truth(:,4), '-', 'DisplayName', 'truth_z', 'LineWidth', 1);
legend show;
xlabel('Time (s)');
ylabel('Data Value');
grid on;
hold off;

subplot(2,2,4);
hold on;
plot(timestamp, data_mag13(:,5), '-', 'DisplayName', 'mag', 'LineWidth', 1);
plot(timestamp, data_mag13_truth(:,5), '-', 'DisplayName', 'truth', 'LineWidth', 1);
legend show;
xlabel('Time (s)');
ylabel('Data Value');
grid on;
hold off;

%% save data
    
% save data to file;
save_file_name='data/Flight1_0814/Flight1_0814_cabin.txt';
fileID = fopen(save_file_name, 'w');
if fileID == -1
    error('cannot open file!');
end
for j=1:size(data_mag13,1)
    fprintf(fileID,'%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', ...
        data_mag13(j,1),data_mag13(j,5),data_mag13(j,2),data_mag13(j,3),data_mag13(j,4),...
        data_mag13_truth(j,5),data_mag13_truth(j,2),data_mag13_truth(j,3),data_mag13_truth(j,4),...
        0,0,0);
end
fclose(fileID);

% save info to file;
save_info_file_name='data/Flight1_0814/Flight1_0814_cabin_info.txt';
fileID = fopen(save_info_file_name, 'w');
if fileID == -1
    error('cannot open file!');
end
%     fprintf(fileID,'mag_earth_intensity = %f\n',mag_earth_intensity);
fprintf(fileID,'saved data field: \n time, mag_op, flux_xyz, mag_op_truth, flux_xyz_truth, ins_pry \n');
fclose(fileID);


