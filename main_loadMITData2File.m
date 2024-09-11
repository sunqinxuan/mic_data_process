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

anomaly_map_filename='Canada_MAG_RES_200m.hdf5';

i = 3;

%%
% for i=1:size(lines,2)
    fprintf('\n***********printing info for line '); disp(lines{i});
    % timestamp
    tt=readH5Field(data_original_filename, lines{i}, '/tt');
    % flux magnetometer measurements
    mag_flux_x=readH5Field(data_original_filename, lines{i}, '/flux_c_x');
    mag_flux_y=readH5Field(data_original_filename, lines{i}, '/flux_c_y');
    mag_flux_z=readH5Field(data_original_filename, lines{i}, '/flux_c_z');
    mag_op=readH5Field(data_original_filename, lines{i}, '/mag_5_uc');
    mag_op_truth=readH5Field(data_original_filename, lines{i}, '/mag_1_uc');
    % ins computed attitude
    ins_pitch=readH5Field(data_original_filename, lines{i}, '/ins_pitch');
    ins_roll=readH5Field(data_original_filename, lines{i}, '/ins_roll');
    ins_yaw=readH5Field(data_original_filename, lines{i}, '/ins_yaw');
    % WGS-84 UTM coordinate (for anomaly map reading)
    utm_x=readH5Field(data_original_filename, lines{i}, '/utm_x');
    utm_y=readH5Field(data_original_filename, lines{i}, '/utm_y');
    % diurnal
    diurnal=readH5Field(data_original_filename, lines{i}, '/diurnal');
    % latitude/longitude/height (for IGRF reading)
    baro=readH5Field(data_original_filename, lines{i}, '/baro');
    lat=readH5Field(data_original_filename, lines{i}, '/lat');
    lon=readH5Field(data_original_filename, lines{i}, '/lon');

    [mag_anomaly,map_idx_x,map_idx_y]=read_anomaly_map(anomaly_map_filename,utm_x,utm_y);

    mag_earth=zeros(size(tt));
    igrf_north=zeros(size(tt));
    igrf_east=zeros(size(tt));
    igrf_down=zeros(size(tt));
    gh = loadigrfcoefs(time);
    for j=1:size(tt,1)
        latitude=lat(j);
        longitude=lon(j);
        altitude=baro(j)*1e-3;
        [Bx, By, Bz] = igrf(gh, latitude, longitude, altitude, 'geod');
        mag_earth(j)=norm([Bx,By,Bz])+mag_anomaly(j)+diurnal(j);
        igrf_north(j)=Bx;
        igrf_east(j)=By;
        igrf_down(j)=Bz;
    end
    mag_earth_intensity=mean(mag_earth);
    fprintf('mag_earth_intensity ='); disp(mag_earth_intensity);
    
    % save data to file;
    cell_str=strsplit(data_original_filename,'_');
    save_file_name=['data/',cell_str{1,1},'_',num2str(lines{i}),'.txt'];
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

    % save info data to file;
    save_info_file_name=['data/',cell_str{1,1},'_',num2str(lines{i}),'_info.txt'];
    fileID = fopen(save_info_file_name, 'w');
    if fileID == -1
        error('cannot open file!');
    end
%     fprintf(fileID,'mag_earth_intensity = %f\n',mag_earth_intensity);
    fprintf(fileID,'saved data field: \n time, mag_op, flux_xyz, mag_op_truth, igrf_ned, ins_pry \n');
    fclose(fileID);
    
    % show flight trajectory on anomaly map;
%     img_traj=showAnomalyMapTraj(anomaly_map_filename,map_idx_x,map_idx_y,save_file_name);
% end


fprintf('\nmean(baro) = '); disp(mean(baro));