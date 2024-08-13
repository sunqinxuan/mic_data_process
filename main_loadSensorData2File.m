clc
clear
close all

addpath('.\data')

%% read mag13 data

data_csv=readData_csv('.\data\uav0729\mag_13\Mag13_2024-07-29-10-44-25.csv');

time=table2array(data_csv(:,1));
[h,m,s] = hms(time);
timestamp= h.*3600+m.*60+s;

x_m=table2array(data_csv(:,2));
y_m=table2array(data_csv(:,3));
z_m=table2array(data_csv(:,4));

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

%% read uav position data

data_csv=readData_csv('.\data\uav0729\dji_m350rtk\EulerAngles_2024-07-29-10-44-25.csv');

time=table2array(data_csv(:,1));
[h,m,s] = hms(time);
timestamp= h.*3600+m.*60+s;

pitch=table2array(data_csv(:,2)); % deg
roll=table2array(data_csv(:,3)); % deg
yaw=table2array(data_csv(:,4)); % deg

data_orientation=[timestamp,pitch,roll,yaw];

%%


