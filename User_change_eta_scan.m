
% 通感通信仿真：频谱占比 η 扫描 + 用户数/方向敏感性分析
% 作者：ChatGPT + 用户自定义扩展

clc; clear; close all;

% 基本系统参数
fc = 28e9;                      % 载波频率 28 GHz
c = physconst('LightSpeed');  
lambda = c/fc;                  % 波长
Btotal = 100e6;                 % 总带宽 100 MHz
N0 = 1e-11;                     % 噪声功率谱密度
Pt = 1;                         % 发射总功率
N = 16;                         % 阵列天线数

% 通信频谱占比扫描范围
eta_list = 0.1:0.05:0.9;

% 用户数设置（测试不同数量）
userConfigs = {
    [-45, 0, 45],            % 3 用户
    [-60, -20, 20, 60],      % 4 用户
    [-60, -30, 0, 30, 60]    % 5 用户
};

% 构建阵列与导向矢量对象
array = phased.ULA('NumElements', N, 'ElementSpacing', lambda/2);
steervec = phased.SteeringVector('SensorArray', array, 'PropagationSpeed', c);

% 为每种用户配置记录结果
figure; hold on;
colors = ['r', 'g', 'b']; legends = {};

for idx = 1:length(userConfigs)
    userAngles = userConfigs{idx};
    legends{end+1} = [num2str(length(userAngles)), ' 用户'];

    % 生成合成波束权重
    weights = zeros(N,1);
    for i = 1:length(userAngles)
        ang = [userAngles(i); 0];  % [方位角; 俯仰角]
        weights = weights + steervec(fc, ang);
    end
    weights = weights / norm(weights);  % 归一化权重

    % 方向向量与增益
    ang = [userAngles; zeros(1,length(userAngles))];  % 多角度
    sv = steervec(fc, ang);                           % 导向矢量矩阵
    gain = abs(weights' * sv).^2;                     % 每个用户方向上的增益

    % 扫描 η 并记录速率
    sumRates = zeros(size(eta_list));
    for j = 1:length(eta_list)
        eta = eta_list(j);
        SNR = Pt * gain / (N0 * eta * Btotal);
        rate = eta * Btotal * log2(1 + SNR);
        sumRates(j) = sum(rate);
    end

    % 绘图
    plot(eta_list, sumRates / 1e6, [colors(idx), '-o'], 'LineWidth', 2);
end

% 图形设置
grid on;
xlabel('通信频谱占比 η');
ylabel('总通信速率 (Mbps)');
title('不同用户数/角度配置下 η 对通信速率影响');
legend(legends, 'Location', 'northwest');
