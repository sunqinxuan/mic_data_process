function sim_compensate_1002_02(tt,lon,lat,baro,mag_measure,mag_truth,mag_comp,delta,delta_comp)

% 创建一个图形窗口
fig = figure('Name', 'Magnetic Compensation Simulation', 'NumberTitle', 'off', ...
             'Position', [100, 100, 600, 400], ...  % 初始大小
             'WindowState', 'maximized');  % 最大化窗口

uicontrol('Style', 'text', 'Units', 'normalized', ...
          'Position', [0.4, 0.85, 0.5, 0.1], ...
          'String', '磁干扰补偿模型测试系统', 'HorizontalAlignment', 'left', ...
          'FontSize', 50);

yy=0.2;
tt_range=[5.73e4, 6.03e4];

% 创建一个按钮用于从文件载入模型
uicontrol('Style', 'pushbutton', 'Units', 'normalized', ...
          'Position', [0.8, yy+0.6, 0.15, 0.03], ...
          'String', '从文件载入模型', ...
          'FontSize', 15, ...
          'Callback', @loadModelFromFile);

% 创建一个静态文本框，用于显示载入状态
statusText = uicontrol('Style', 'edit', 'Units', 'normalized', ...
                       'Position', [0.8, yy+0.55, 0.15, 0.05], ...
                       'String', '', 'HorizontalAlignment', 'left', ...
                       'FontSize', 13, 'ForegroundColor', 'green','Max',2,'Enable', 'inactive');

% % 创建一个静态文本框，用于显示提示文字，设置Units为normalized
% uicontrol('Style', 'text', 'Units', 'normalized', ...
%           'Position', [0.8, yy+0.5, 0.1, 0.03], ...
%           'String', '输入模型参数D (3x3)', 'HorizontalAlignment', 'left', ...
%           'FontSize', 15);
% % 创建一个文本框，设置默认值为单位矩阵，Units设置为normalized
% txt_D = uicontrol('Style', 'edit', 'Units', 'normalized', ...
%                 'Position', [0.8, yy+0.47, 0.15, 0.03], ...
%                 'String', '0.02 -0.10 0.90; 0.87 0.42 0.02; -0.43 0.85 0.10', ...
%                 'FontSize', 13);
% 
% uicontrol('Style', 'text', 'Units', 'normalized', ...
%           'Position', [0.8, yy+0.4, 0.1, 0.03], ...
%           'String', '输入模型参数o (3x1)', 'HorizontalAlignment', 'left', ...
%           'FontSize', 15);
% txt_o = uicontrol('Style', 'edit', 'Units', 'normalized', ...
%                 'Position', [0.8, yy+0.37, 0.15, 0.03], ...
%                 'String', '-6350.71; -603.63; 3276.72', ...
%                 'FontSize', 13); 

% uicontrol('Style', 'text', 'Units', 'normalized', ...
%           'Position', [0.8, yy+0.3, 0.1, 0.03], ...
%           'String', '输入磁强计测量噪声', 'HorizontalAlignment', 'left', ...
%           'FontSize', 15);
% txt_mag = uicontrol('Style', 'edit', 'Units', 'normalized', ...
%                 'Position', [0.8, yy+0.27, 0.15, 0.03], ...
%                 'String', '1nT', ...
%                 'FontSize', 13); 
% 
% uicontrol('Style', 'text', 'Units', 'normalized', ...
%           'Position', [0.8, yy+0.2, 0.1, 0.03], ...
%           'String', '输入陀螺仪零偏稳定性', 'HorizontalAlignment', 'left', ...
%           'FontSize', 15);
% txt_gyr = uicontrol('Style', 'edit', 'Units', 'normalized', ...
%                 'Position', [0.8, yy+0.17, 0.15, 0.03], ...
%                 'String', '0.001deg/h', ...
%                 'FontSize', 13); 
% 
% uicontrol('Style', 'text', 'Units', 'normalized', ...
%           'Position', [0.8, yy+0.6, 0.1, 0.03], ...
%           'String', '输入飞行高度', 'HorizontalAlignment', 'left', ...
%           'FontSize', 15);
% txt_alt = uicontrol('Style', 'edit', 'Units', 'normalized', ...
%                 'Position', [0.8, yy+0.57, 0.15, 0.03], ...
%                 'String', '3000m', ...
%                 'FontSize', 15); 

% 创建一个按钮，设置Units为normalized，使其能够随窗口缩放
uicontrol('Style', 'pushbutton', 'String', '开始补偿', ...
          'Units', 'normalized', ...  % 设置为相对布局单位
          'Position', [0.8, yy+0.5, 0.1, 0.03], ...  % 相对位置和大小
          'Callback', @startPlot, ...
          'FontSize', 15);

% 创建一个静态文本框，用于实时显示补偿误差
comp_status = uicontrol('Style', 'edit', 'Units', 'normalized', ...
                       'Position', [0.8, 0.4, 0.15, 0.25], ...
                       'String', '', 'HorizontalAlignment', 'left', ...
                       'FontSize', 15, 'ForegroundColor', 'black','Max', 10,'Enable', 'inactive');


% 创建一个三维轴用于显示图形
ax_traj = axes('Parent', fig, 'Position', [0.3, 0.37, 0.45, 0.45]);
title(ax_traj, sprintf('测试飞行轨迹仿真'));
xlabel(ax_traj, '经度/deg');
ylabel(ax_traj, '纬度/deg');
zlabel(ax_traj, '高度/m');
% 设置固定的坐标轴范围
xlim(ax_traj, [-76.65, -76.35]);
ylim(ax_traj, [45.45, 45.65]);
zlim(ax_traj, [2940, 3080]);
% 调整视角 (Azimuth = 45度, Elevation = 30度)
view(ax_traj, [80, 70]); % 设置45度的方位角和30度的仰角
% 启用网格
grid(ax_traj, 'on');

xx=0.05;
dx=0.24;

ax_magx = axes('Parent', fig, 'Position', [xx, 0.05, 0.2, 0.25]);
title(ax_magx, sprintf('X轴磁场分量'));
xlabel(ax_magx, '时间/s');
ylabel(ax_magx, '磁场/nT');
xlim(ax_magx, tt_range);
ylim(ax_magx, [-6e4, 3e4]);
grid(ax_magx, 'on');

ax_magy = axes('Parent', fig, 'Position', [xx+dx, 0.05, 0.2, 0.25]);
title(ax_magy, sprintf('Y轴磁场分量'));
xlabel(ax_magy, '时间/s');
ylabel(ax_magy, '磁场/nT');
xlim(ax_magy, tt_range);
ylim(ax_magy, [-5e4, 4e4]);
grid(ax_magy, 'on');

ax_magz = axes('Parent', fig, 'Position', [xx+2*dx, 0.05, 0.2, 0.25]);
title(ax_magz, sprintf('Z轴磁场分量'));
xlabel(ax_magz, '时间/s');
ylabel(ax_magz, '磁场/nT');
xlim(ax_magz, tt_range);
ylim(ax_magz, [-3e4, 8e4]);
grid(ax_magz, 'on');

ax_mag = axes('Parent', fig, 'Position', [xx+3*dx, 0.05, 0.2, 0.25]);
title(ax_mag, sprintf('磁场总场强'));
xlabel(ax_mag, '时间/s');
ylabel(ax_mag, '磁场/nT');
xlim(ax_mag, tt_range);
ylim(ax_mag, [5.25e4, 5.8e4]);
grid(ax_mag, 'on');

ax_meas = axes('Parent', fig, 'Position', [0.05, 0.7, 0.2, 0.25]);
title(ax_meas, sprintf('测量误差曲线'));
xlabel(ax_meas, '时间/s');
ylabel(ax_meas, '测量误差/nT');
xlim(ax_meas, tt_range);
ylim(ax_meas, [-1e4, 5e4]);
grid(ax_meas, 'on');

ax_comp = axes('Parent', fig, 'Position', [0.05, 0.37, 0.2, 0.25]);
title(ax_comp, sprintf('补偿误差曲线'));
xlabel(ax_comp, '时间/s');
ylabel(ax_comp, '补偿误差/nT');
xlim(ax_comp, tt_range);
ylim(ax_comp, [-40, 100]);
grid(ax_comp, 'on');


% 按钮的回调函数
function startPlot(~, ~)
    % 获取文本框中的字符串
%     matrix_str = get(txt_D, 'String');
%     coeff_D = str2num(matrix_str);  %#ok<ST2NM> 使用str2num解析字符串为矩阵
% %     if isempty(coeff_D) || ~isequal(size(coeff_D), [3, 3])
% %         errordlg('请输入有效的3x3矩阵', '输入错误');
% %         return;
% %     end
%     disp('输入的矩阵为:');
%     disp(coeff_D);
% 
%     matrix_str = get(txt_o, 'String');
%     coeff_o = str2num(matrix_str);  %#ok<ST2NM> 使用str2num解析字符串为矩阵
%     disp('输入的矩阵为:');
%     disp(coeff_o);

%         % 获取用户输入
%         userInput = str2double(get(txt, 'String'));
%         
%         % 检查输入有效性
%         if isnan(userInput) || userInput < 1 || userInput > 10
%             errordlg('Please enter a valid number between 1 and 10.', 'Input Error');
%             return;
%         end

%     userInput=1;
    
    % 清除之前的图形
%     cla(ax_traj);
    
    % 固定 Z 轴数据
%     zData = rand() * 5; % 随机生成一个固定的Z轴数据
    
    % 动态生成数据
%     newData = zeros(1, 10); % 初始化数据
    N=size(lon,1);

    % 创建图例对象，只创建一次
%     traj_legend = legend(ax_traj, '飞机轨迹', '飞机位置', 'Location', 'best');
%     magx_legend = legend(ax_magx, '测量磁场', '地球磁场', 'Location', 'best');

    for i = 1:100:N
        pause(0.0001); % 暂停以模拟生成过程
%         newData(i) = rand() * userInput; % 根据输入调整数据
        
        cla(ax_traj); % 清除当前轨迹数据
        % 绘制三维曲线
%         plot3(ax_traj, 1:i, newData(1:i), zData * ones(1, i), 'b-','LineWidth',1); % 绘制到当前点的连贯三维曲线
        plot3(ax_traj, lon(1:i), lat(1:i), baro(1:i), 'b-','LineWidth',1,'DisplayName','飞机轨迹');

        % 绘制飞机形状
        hold(ax_traj, 'on');
%         planeX = [i - 0.5, i, i - 0.5]; % 飞机的X坐标
%         planeY = [newData(i) - 0.5, newData(i) + 0.5, newData(i) + 0.5]; % 飞机的Y坐标
%         planeZ = [zData - 0.5, zData + 0.5, zData + 0.5]; % 飞机的Z坐标
%         fill3(ax_traj, planeX, planeY, planeZ, 'r'); % 使用fill3绘制飞机形状
        scatter3(ax_traj,lon(i),lat(i),baro(i),'r','filled','DisplayName','飞机位置');
        hold(ax_traj, 'off');

        title(ax_traj, sprintf('测试飞行轨迹仿真'));
        xlabel(ax_traj, '经度/deg');
        ylabel(ax_traj, '纬度/deg');
        zlabel(ax_traj, '高度/m');
        xlim(ax_traj, [-76.5, -75.3]);
        ylim(ax_traj, [44.5, 45.1]);
        zlim(ax_traj, [0, 600]);
        view(ax_traj, [80, 70]); 
        grid(ax_traj, 'on');
        legend(ax_traj);
        drawnow;

        cla(ax_magx);
        hold(ax_magx,'on');
        plot(ax_magx,tt(1:i),mag_measure(1:i,1),'b','LineWidth',1,'DisplayName','测量磁场'); 
        plot(ax_magx,tt(1:i),mag_truth(1:i,1),'r','LineWidth',1,'DisplayName','地球磁场'); 
        plot(ax_magx,tt(1:i),mag_comp(1:i,1),'k--','LineWidth',1,'DisplayName','补偿后测量磁场'); 
        hold(ax_magx, 'off');
        title(ax_magx, sprintf('X轴磁场分量'));
        xlabel(ax_magx, '时间/s');
        ylabel(ax_magx, '磁场/nT');
        xlim(ax_magx, tt_range);
        ylim(ax_magx, [-6e4, 3e4]);
        grid(ax_magx, 'on');
        legend(ax_magx);
        drawnow;

        cla(ax_magy);
        hold(ax_magy,'on');
        plot(ax_magy,tt(1:i),mag_measure(1:i,2),'b','LineWidth',1,'DisplayName','测量磁场'); 
        plot(ax_magy,tt(1:i),mag_truth(1:i,2),'r','LineWidth',1,'DisplayName','地球磁场'); 
        plot(ax_magy,tt(1:i),mag_comp(1:i,2),'k--','LineWidth',1,'DisplayName','补偿后测量磁场'); 
        hold(ax_magy, 'off');
        title(ax_magy, sprintf('Y轴磁场分量'));
        xlabel(ax_magy, '时间/s');
        ylabel(ax_magy, '磁场/nT');
        xlim(ax_magy, tt_range);
        ylim(ax_magy, [-5e4, 4e4]);
        grid(ax_magy, 'on');
        legend(ax_magy);
        drawnow;

        cla(ax_magz);
        hold(ax_magz,'on');
        plot(ax_magz,tt(1:i),mag_measure(1:i,3),'b','LineWidth',1,'DisplayName','测量磁场'); 
        plot(ax_magz,tt(1:i),mag_truth(1:i,3),'r','LineWidth',1,'DisplayName','地球磁场'); 
        plot(ax_magz,tt(1:i),mag_comp(1:i,3),'k--','LineWidth',1,'DisplayName','补偿后测量磁场'); 
        hold(ax_magz, 'off');
        title(ax_magz, sprintf('Z轴磁场分量'));
        xlabel(ax_magz, '时间/s');
        ylabel(ax_magz, '磁场/nT');
        xlim(ax_magz, tt_range);
        ylim(ax_magz, [-3e4, 8e4]);
        grid(ax_magz, 'on');
        legend(ax_magz);
        drawnow;

        cla(ax_mag);
        hold(ax_mag,'on');
        plot(ax_mag,tt(1:i),mag_measure(1:i,4),'b','LineWidth',1,'DisplayName','测量磁场'); 
        plot(ax_mag,tt(1:i),mag_truth(1:i,4),'r','LineWidth',1,'DisplayName','地球磁场'); 
        plot(ax_mag,tt(1:i),mag_comp(1:i,4),'k--','LineWidth',1,'DisplayName','补偿后测量磁场'); 
        hold(ax_mag, 'off');
        title(ax_mag, sprintf('磁场总场强'));
        xlabel(ax_mag, '时间/s');
        ylabel(ax_mag, '磁场/nT');
        xlim(ax_mag, tt_range);
        ylim(ax_mag, [5.25e4, 5.8e4]);
        grid(ax_mag, 'on');
        legend(ax_mag);
        drawnow;

        cla(ax_meas);
        hold(ax_meas,'on');
        plot(ax_meas,tt(1:i),delta(1:i,1),'b','LineWidth',1,'DisplayName','X轴分量'); 
        plot(ax_meas,tt(1:i),delta(1:i,2),'r','LineWidth',1,'DisplayName','X轴分量'); 
        plot(ax_meas,tt(1:i),delta(1:i,3),'g','LineWidth',1,'DisplayName','Z轴分量'); 
        plot(ax_meas,tt(1:i),delta(1:i,4),'k','LineWidth',1,'DisplayName','磁场总量');
        hold(ax_meas, 'off');
        title(ax_meas, sprintf('测量误差曲线'));
        xlabel(ax_meas, '时间/s');
        ylabel(ax_meas, '测量误差/nT');
        xlim(ax_meas, tt_range);
        ylim(ax_meas, [-1e4, 5e4]);
        grid(ax_meas, 'on');
        legend(ax_meas);
        drawnow;

        cla(ax_comp);
        hold(ax_comp,'on');
        plot(ax_comp,tt(1:i),delta_comp(1:i,1),'b','LineWidth',1,'DisplayName','X轴分量'); 
        plot(ax_comp,tt(1:i),delta_comp(1:i,2),'r','LineWidth',1,'DisplayName','X轴分量'); 
        plot(ax_comp,tt(1:i),delta_comp(1:i,3),'g','LineWidth',1,'DisplayName','Z轴分量'); 
        plot(ax_comp,tt(1:i),delta_comp(1:i,4),'k','LineWidth',1,'DisplayName','磁场总量');
        hold(ax_comp, 'off');
        title(ax_comp, sprintf('补偿误差曲线'));
        xlabel(ax_comp, '时间/s');
        ylabel(ax_comp, '补偿误差/nT');
        xlim(ax_comp, tt_range);
        ylim(ax_comp, [-40, 100]);
        grid(ax_comp, 'on');
        legend(ax_comp);
        drawnow;

        rmse_x=abs(mean(delta(1:i,1)));
        rmse_y=abs(mean(delta(1:i,2)));
        rmse_z=abs(mean(delta(1:i,3)));
        rmse_mag=abs(mean(delta(1:i,4)));
        rmse_x_comp=abs(mean(delta_comp(1:i,1)));
        rmse_y_comp=abs(mean(delta_comp(1:i,2)));
        rmse_z_comp=abs(mean(delta_comp(1:i,3)));
        rmse_mag_comp=abs(mean(delta_comp(1:i,4)));

        set(comp_status, 'String', sprintf('实时测量误差：\nX轴分量：%.2fnT\nY轴分量：%.2fnT\nZ轴分量：%.2fnT\n总场强：%.2fnT\n\n实时补偿误差：\nX轴分量：%.2fnT\nY轴分量：%.2fnT\nZ轴分量：%.2fnT\n总场强：%.2fnT', ...
            rmse_x,rmse_y,rmse_z,rmse_mag,rmse_x_comp,rmse_y_comp,rmse_z_comp,rmse_mag_comp));
    end

end

% 定义载入模型的回调函数
function loadModelFromFile(~, ~)
    [file, path] = uigetfile('*.mdl', '选择模型文件');
    if isequal(file, 0)
        disp('用户取消了文件选择');
    else
        filename = fullfile(path, file);
%         try
            % 载入 Simulink 模型
%             load_system(filename);  % 载入 .mdl 文件
            % 更新状态文本为“载入模型成功！”
            set(statusText, 'String', sprintf('载入模型成功:\n%s', filename));
            disp(['模型载入成功: ', filename]);
%         catch ME
%             disp('载入文件时发生错误:');
%             disp(ME.message);
%             % 更新状态文本为红色的“载入模型失败！”
%             set(statusText, 'String', '载入模型失败！', 'ForegroundColor', 'red');
%         end
    end
end

end