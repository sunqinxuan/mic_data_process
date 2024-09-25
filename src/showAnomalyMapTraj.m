function img=showAnomalyMapTraj(anomaly_map_filename,map_idx_x,map_idx_y,figure_name)

anomaly_map= h5read(anomaly_map_filename,'/map');
max_value=max(max(anomaly_map));
img_traj=anomaly_map;
for i=1:size(map_idx_x,1)
    img_traj(map_idx_y(i),map_idx_x(i))=max_value;
    img_traj(map_idx_y(i)-1,map_idx_x(i))=max_value;
    img_traj(map_idx_y(i),map_idx_x(i)-1)=max_value;
    img_traj(map_idx_y(i)+1,map_idx_x(i))=max_value;
    img_traj(map_idx_y(i),map_idx_x(i)+1)=max_value;
end

img=img_traj;
N=size(img_traj,1);
for i=1:N
    img(i,:)=img_traj(N+1-i,:);
end

figure;
title(figure_name);
imshow(img,[]);