clc
clear
close all

addpath('.\data')
time_in=[2024 7 29];
range=1:7370;

%% read mag13 data

data_csv=readData_csv('.\data\uav0729\mag_13\Mag13_2024-07-29-10-44-25.csv');

time=table2array(data_csv(range,1));
[h,m,s] = hms(time);
timestamp= h.*3600+m.*60+s;

x_m=table2array(data_csv(range,2));
y_m=table2array(data_csv(range,3));
z_m=table2array(data_csv(range,4));

data_mag13=[timestamp,x_m,y_m,z_m];

%% read quspin data

data_csv=readData_csv('.\data\uav0729\qtfm_gen_2\QtfmGen2_2024-07-29-10-44-25.csv');

time=table2array(data_csv(:,1));
[h,m,s] = hms(time);
timestamp= h.*3600+m.*60+s;

mag=table2array(data_csv(:,3));

data_quspin=[timestamp,mag];

%% read uav position data

data_csv=readData_csv('.\data\uav0729\dji_m350rtk\PositionFused_2024-07-29-10-44-25.csv');

time=table2array(data_csv(:,1));
[h,m,s] = hms(time);
timestamp= h.*3600+m.*60+s;

longitude=table2array(data_csv(:,2))*180.0/pi; % deg
latitude=table2array(data_csv(:,3))*180.0/pi; % deg
altitude=table2array(data_csv(:,4))*1e-3; % km

data_position=[timestamp,longitude,latitude,altitude];

%% read uav orientation data

data_csv=readData_csv('.\data\uav0729\dji_m350rtk\EulerAngles_2024-07-29-10-44-25.csv');

time=table2array(data_csv(:,1));
[h,m,s] = hms(time);
timestamp= h.*3600+m.*60+s;

pitch=table2array(data_csv(:,2)); % deg
roll=table2array(data_csv(:,3)); % deg
yaw=table2array(data_csv(:,4)); % deg

data_orientation=[timestamp,pitch,roll,yaw];

%% compute mag_earth_intensity

timedate = datenum(time_in);
gh = loadigrfcoefs(timedate);

mag_earth=zeros(size(data_position,1),1);
igrf_north=zeros(size(data_position,1),1);
igrf_east=zeros(size(data_position,1),1);
igrf_down=zeros(size(data_position,1),1);

for j=1:size(data_position,1)
    latitude=data_position(j,3);
    longitude=data_position(j,2);
    altitude=data_position(j,4);
    [Bx, By, Bz] = igrf(gh, latitude, longitude, altitude, 'geod');
    mag_earth(j)=norm([Bx,By,Bz]);%+mag_anomaly(j)+diurnal(j);
    igrf_north(j)=Bx;
    igrf_east(j)=By;
    igrf_down(j)=Bz;
end

data_igrf=[data_position(:,1),igrf_north,igrf_east,igrf_down];

mag_earth_intensity=mean(mag_earth);
fprintf('mag_earth_intensity =');
disp(mag_earth_intensity);

%% time synchronization

sync_orientation=zeros(size(data_mag13));
idx_orienttion=1;
sync_igrf=zeros(size(data_mag13));
idx_igrf=1;
for i=1:size(data_mag13,1)
    t=data_mag13(i,1);
    for j=idx_orienttion:size(data_orientation,1)
        tt=data_orientation(j,1);
        if abs(t-tt)<0.05
            sync_orientation(i,:)=data_orientation(j,:);
            idx_orienttion=j;
            break;
        end
    end
    for j=idx_igrf:size(data_igrf,1)
        tt=data_igrf(j,1);
        if abs(t-tt)<0.05
            sync_igrf(i,:)=data_igrf(j,:);
            idx_igrf=j;
            break;
        end
    end
end

% figure;
% plot(data_mag13(:,1),'r'); hold on;
% plot(tmp_orientation(:,1),'g'); hold on;
% plot(tmp_igrf(:,1),'b'); hold on;

%% 

tt=datetime(time_in);
time_str=datestr(tt,'yyyy-mm-dd');

% save data to file;
% cell_str=strsplit(data_original_filename,'_');
% save_file_name=['data/',cell_str{1,1},'_',num2str(lines{i}),'.txt'];
save_file_name=['data/data_',time_str,'.txt'];
fileID = fopen(save_file_name, 'w');
if fileID == -1
    error('cannot open file!');
end
for j=1:size(data_mag13,1)
    fprintf(fileID,'%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', ...
        data_mag13(j,1),data_mag13(j,2),data_mag13(j,3),data_mag13(j,4),...
        sync_orientation(j,2),sync_orientation(j,3),sync_orientation(j,4),...
        sync_igrf(j,2),sync_igrf(j,3),sync_igrf(j,4));
end
fclose(fileID);

% save info data to file;
save_info_file_name=['data/data_',time_str,'_info.txt'];
fileID = fopen(save_info_file_name, 'w');
if fileID == -1
    error('cannot open file!');
end
fprintf(fileID,'mag_earth_intensity = %f\n',mag_earth_intensity);
fprintf(fileID,'saved data field: \n time, flux_xyz, ins_pry, igrf_ned \n');
fclose(fileID);



