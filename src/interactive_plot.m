function interactive_plot(tt,lon,lat,baro,mag_measure,mag_truth)

% 创建一个图形窗口
fig = figure('Name', 'Magnetic Compensation Simulation', 'NumberTitle', 'off', ...
             'Position', [100, 100, 600, 400], ...  % 初始大小
             'WindowState', 'maximized');  % 最大化窗口

% 创建一个按钮，设置Units为normalized，使其能够随窗口缩放
uicontrol('Style', 'pushbutton', 'String', '生成仿真数据', ...
          'Units', 'normalized', ...  % 设置为相对布局单位
          'Position', [0.8, 0.05, 0.1, 0.03], ...  % 相对位置和大小
          'Callback', @startPlot, ...
          'FontSize', 13);

% 创建一个静态文本框，用于显示提示文字，设置Units为normalized
uicontrol('Style', 'text', 'Units', 'normalized', ...
          'Position', [0.8, 0.9, 0.1, 0.03], ...
          'String', '输入系统矩阵 (3x3)', 'HorizontalAlignment', 'left', ...
          'FontSize', 15);

% 创建一个文本框，设置默认值为单位矩阵，Units设置为normalized
txt = uicontrol('Style', 'edit', 'Units', 'normalized', ...
                'Position', [0.8, 0.87, 0.15, 0.03], ...
                'String', '1 0 0; 0 1 0; 0 0 1', ...
                'FontSize', 13);  % 单位矩阵作为默认值

% 创建一个三维轴用于显示图形
ax_traj = axes('Parent', fig, 'Position', [0.05, 0.1, 0.45, 0.45]);
title(ax_traj, sprintf('仿真轨迹生成'));
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

ax_magx = axes('Parent', fig, 'Position', [0.05, 0.65, 0.2, 0.25]);
title(ax_magx, sprintf('X轴磁场分量'));
xlabel(ax_magx, '时间/s');
ylabel(ax_magx, '磁场/nT');
% 设置固定的坐标轴范围
xlim(ax_magx, [4.63e4, 4.77e4]);
ylim(ax_magx, [-6e4, 3e4]);
% 启用网格
grid(ax_magx, 'on');

ax_magy = axes('Parent', fig, 'Position', [0.3, 0.65, 0.2, 0.25]);

ax_magz = axes('Parent', fig, 'Position', [0.55, 0.65, 0.2, 0.25]);

ax_pr = axes('Parent', fig, 'Position', [0.55, 0.35, 0.2, 0.25]);

ax_yaw = axes('Parent', fig, 'Position', [0.55, 0.05, 0.2, 0.25]);


% 按钮的回调函数
function startPlot(~, ~)
    % 获取文本框中的字符串
    matrix_str = get(txt, 'String');
    
    % 将字符串转换为矩阵
    matrix = str2num(matrix_str);  %#ok<ST2NM> 使用str2num解析字符串为矩阵
    
    % 检查输入是否为3x3矩阵
    if isempty(matrix) || ~isequal(size(matrix), [3, 3])
        errordlg('请输入有效的3x3矩阵', '输入错误');
        return;
    end
    
    % 显示或处理矩阵
    disp('输入的矩阵为:');
    disp(matrix);

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

    for i = 1:50:N
        pause(0.001); % 暂停以模拟生成过程
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

        title(ax_traj, sprintf('Simulated Trajectory'));
        xlabel(ax_traj, '经度/deg');
        ylabel(ax_traj, '纬度/deg');
        zlabel(ax_traj, '高度/m');
        xlim(ax_traj, [-76.65, -76.35]);
        ylim(ax_traj, [45.45, 45.65]);
        zlim(ax_traj, [2940, 3080]);
        view(ax_traj, [80, 70]); 
        % 确保网格始终可见
        grid(ax_traj, 'on');
        legend(ax_traj);

        drawnow; % 更新图形

        cla(ax_magx);

        hold(ax_magx,'on');
        plot(ax_magx,tt(1:i),mag_measure(1:i,1),'b','LineWidth',1,'DisplayName','测量磁场'); 
        plot(ax_magx,tt(1:i),mag_truth(1:i,1),'r','LineWidth',1,'DisplayName','地球磁场'); 
        
        hold(ax_magx, 'off');
        title(ax_magx, sprintf('X轴磁场分量'));
        xlabel(ax_magx, '时间/s');
        ylabel(ax_magx, '磁场/nT');
        % 设置固定的坐标轴范围
        xlim(ax_magx, [4.63e4, 4.77e4]);
        ylim(ax_magx, [-6e4, 3e4]);
        % 启用网格
        grid(ax_magx, 'on');
        legend(ax_magx);

        drawnow; % 更新图形
    end
end

end