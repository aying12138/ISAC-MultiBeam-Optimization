
% 通感一体化通信侧波束赋形与动态频谱扫描仿真
% 功能扩展：扫描 η ∈ [0.1, 0.9]，绘制 η vs 总通信速率曲线

clc; clear; close all;

% 基本参数设置
N = 16;               % 阵列天线数（建议16或32）
fc = 28e9;            % 载波频率 28 GHz
c = physconst('LightSpeed');  
lambda = c/fc;        % 波长
Btotal = 100e6;       % 系统总带宽 100 MHz
N0 = 1e-11;           % 噪声功率谱密度（W/Hz）
Pt = 1;               % 发射总功率（W）

userAngles = [-30, 0, 45];  % 多个通信用户方位角（度）

% 构建阵列与导向矢量
array = phased.ULA('NumElements', N, 'ElementSpacing', lambda/2);
steervec = phased.SteeringVector('SensorArray', array, 'PropagationSpeed', c);

% 多用户波束权重叠加
weights = zeros(N,1);
for i = 1:length(userAngles)
    ang = [userAngles(i); 0];    % 方位角 + 俯仰角
    weights = weights + steervec(fc, ang);
end
weights = weights / norm(weights);  % 归一化，保持单位功率

% 扫描 η 范围并记录总速率
eta_list = 0.1:0.05:0.9;  % 频谱占比范围
sumRates = zeros(size(eta_list));

% 角度矩阵与阵列增益（固定）
ang = [userAngles; zeros(1,length(userAngles))];  % 构造 M×2 角度矩阵
sv = steervec(fc, ang);                           % N×M 导向矢量矩阵
gain = abs(weights' * sv).^2;                     % 每个用户方向上的增益（线性）

% 频谱比例遍历
for i = 1:length(eta_list)
    eta = eta_list(i);
    SNR = Pt * gain / (N0 * eta * Btotal);        % 简化信噪比估算
    rate = eta * Btotal * log2(1 + SNR);          % 通信速率 (bps)
    sumRates(i) = sum(rate);                      % 总速率
end

% 绘图展示 η vs 总通信速率
figure;
plot(eta_list, sumRates / 1e6, 'b-o', 'LineWidth', 2);
grid on;
xlabel('通信频谱占比 η');
ylabel('总通信速率 (Mbps)');
title('频谱占比 η 对通信总速率的影响');
