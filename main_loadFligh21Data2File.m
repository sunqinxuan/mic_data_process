clc
clear
close all

addpath('.\src')
addpath('.\data')
addpath('.\m_IGRF')

time = datenum([2024 9 9]); 

%% read mag13 data

data_csv=readData_csv('.\data\Flight8_0909\06_mag13\MAG13_3data_20240909_042505.csv');

tt=table2array(data_csv(:,1));
[h,m,s] = hms(tt);
timestamp= h.*3600+m.*60+s;

x_m=table2array(data_csv(:,2));
y_m=table2array(data_csv(:,3));
z_m=table2array(data_csv(:,4));
mag=table2array(data_csv(:,5));

data_mag13=[timestamp,x_m,y_m,z_m,mag];

%% read INS data

filename = '.\data\Flight8_0909\03_INS\INS_result_align6h_10hz_systime.txt';
fileID = fopen(filename, 'r');
data = textscan(fileID, '%s %s %f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
fclose(fileID);

tt_str = data{1};
tt = datetime(tt_str, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
[h,m,s] = hms(tt);
timestamp= h.*3600+m.*60+s;

ins_pitch=data{9}; % deg
ins_roll=data{10};
ins_yaw=data{11};

data_ins=[timestamp,ins_pitch,ins_roll,ins_yaw];

%% read GNSS data

data_csv=readData_csv('.\data\Flight8_0909\10_GNSS\GNSS_20240909_042748_out.csv');

tt=table2array(data_csv(:,1));
[h,m,s] = hms(tt);
timestamp= h.*3600+m.*60+s;

lat=table2array(data_csv(:,2)); % deg
lon=table2array(data_csv(:,3)); % deg
alt=table2array(data_csv(:,4)); % m

data_gnss=[timestamp,lat,lon,alt];

%% read IGRF data

dim_gnss=[size(data_gnss,1),1];
mag_earth=zeros(dim_gnss);
igrf_north=zeros(dim_gnss);
igrf_east=zeros(dim_gnss);
igrf_down=zeros(dim_gnss);
gh = loadigrfcoefs(time);
for j=1:size(data_gnss,1)
    latitude=lat(j);
    longitude=lon(j);
    altitude=alt(j)*1e-3;
    [Bx, By, Bz] = igrf(gh, latitude, longitude, altitude, 'geod');
    mag_earth(j)=norm([Bx,By,Bz]);
    igrf_north(j)=Bx;
    igrf_east(j)=By;
    igrf_down(j)=Bz;
end
mag_earth_intensity=mean(mag_earth);
fprintf('mag_earth_intensity ='); disp(mag_earth_intensity);

%% time synchronization


% 先根据飞行记录，滤掉前后无用数据
% 再用下面提供的插值方法，进行时间对齐 

figure;
plot(data_mag13(:,1),data_mag13(:,5),'r'); hold on;
plot(data_ins(:,1),data_ins(:,4),'g'); hold on;
plot(data_gnss(:,1),data_gnss(:,4),'b'); hold on;



% 假设以下是两组传感器的数据
% 第一组传感器，10 Hz 采集频率，时间间隔为 0.1 秒
time_sensor1 = (0:0.1:10)';  % 低频传感器时间戳 (10 Hz)
data_sensor1 = sin(time_sensor1);  % 假设的低频传感器数据

% 第二组传感器，20 Hz 采集频率，时间间隔为 0.05 秒
time_sensor2 = (0:0.05:10)';  % 高频传感器时间戳 (20 Hz)
data_sensor2 = cos(time_sensor2);  % 假设的高频传感器数据

% 目标：将高频数据对齐到低频的时间轴 (time_sensor1)

% 对第二个传感器数据使用插值，将其对齐到第一个传感器的时间戳上
data_sensor2_interp = interp1(time_sensor2, data_sensor2, time_sensor1, 'linear');

% 将对齐后的数据组合成表格
T = table(time_sensor1, data_sensor1, data_sensor2_interp, ...
    'VariableNames', {'Time', 'Sensor1', 'Sensor2_Aligned'});

% 显示对齐后的数据
disp(T);

% 画图比较对齐效果
figure;
plot(time_sensor1, data_sensor1, 'o-', 'DisplayName', 'Sensor1 (10Hz)');
hold on;
plot(time_sensor2, data_sensor2, 'x-', 'DisplayName', 'Sensor2 Original (20Hz)');
plot(time_sensor1, data_sensor2_interp, 's-', 'DisplayName', 'Sensor2 Interpolated (Aligned to 10Hz)');
xlabel('Time (s)');
ylabel('Data');
legend;
title('Sensor Data Time Alignment (High Freq to Low Freq)');
hold off;




%% save data
    
% save data to file;
save_file_name='data/Flight8_0909.txt';
fileID = fopen(save_file_name, 'w');
if fileID == -1
    error('cannot open file!');
end
for j=1:size(tt,1)
    fprintf(fileID,'%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', ...
        tt(j),mag_op(j),mag_flux_x(j),mag_flux_y(j),mag_flux_z(j),...
        mag_op_truth(j),igrf_north(j),igrf_east(j),igrf_down(j),...
        ins_pitch(j),ins_roll(j),ins_yaw(j));
end
fclose(fileID);

% save info to file;
save_info_file_name='data/Flight8_0909_info.txt';
fileID = fopen(save_info_file_name, 'w');
if fileID == -1
    error('cannot open file!');
end
%     fprintf(fileID,'mag_earth_intensity = %f\n',mag_earth_intensity);
fprintf(fileID,'saved data field: \n time, mag_op, flux_xyz, mag_op_truth, igrf_ned, ins_pry \n');
fclose(fileID);

% show flight trajectory on anomaly map;
img_traj=showAnomalyMapTraj(anomaly_map_filename,map_idx_x,map_idx_y,save_file_name);
% end

%%
fprintf('\n平均飞行高度（气压计）： '); disp(mean(baro));

save_file_name_mat=['data/',cell_str{1,1},'_',num2str(lines{i}),'.mat'];
save(save_file_name_mat,"tt","lat","lon","baro","igrf_down","igrf_east","igrf_north","ins_yaw","ins_roll","ins_pitch");

