
% 通感一体化通信侧波束赋形与动态频谱仿真
clc; clear; close all;

% 基本参数设置
N = 16;               % 阵列天线数（建议16或32）
fc = 28e9;            % 载波频率 28 GHz
c = physconst('LightSpeed');  
lambda = c/fc;        % 波长
Btotal = 100e6;       % 系统总带宽 100 MHz
N0 = 1e-11;           % 噪声功率谱密度（W/Hz）
Pt = 1;               % 发射总功率（W）
eta = 0.5;            % 通信频谱占比（0~1之间可调）

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

% 绘制方向图
figure;
pattern(array, fc, -90:0.5:90, 0, ...
    'CoordinateSystem','polar', 'Type','powerdb', 'Weights', weights);
title('阵列方向图 (归一化增益)');

% 计算各用户接收增益与信噪比
ang = [userAngles; zeros(1,length(userAngles))];  % 构造 M×2 角度矩阵
sv = steervec(fc, ang);                           % N×M 导向矢量矩阵
gain = abs(weights' * sv).^2;                     % 每个用户方向上的增益（线性）
SNR = Pt * gain / (N0 * eta * Btotal);            % 简化信噪比估算
rate = eta * Btotal * log2(1 + SNR);              % 通信速率 (bps)
sumRate = sum(rate);                              % 总速率

% 输出结果
disp('=== 仿真结果 ===');
disp(['用户角度 (°)：', num2str(userAngles)]);
disp(['阵列增益 (线性)：', num2str(gain)]);
disp(['信噪比 (线性)：', num2str(SNR)]);
disp(['各用户速率 (Mbps)：', num2str(rate / 1e6)]);
disp(['总通信速率 (Mbps)：', num2str(sumRate / 1e6)]);
