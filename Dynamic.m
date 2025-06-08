
% 通感通信仿真：用户角度动态 + η闭环频谱调节 + 通信速率演化
% 作者：ChatGPT + 用户自定义内容

clc; clear; close all;

% 参数设置
fc = 28e9;                    % 载波频率 (Hz)
c = physconst('LightSpeed'); 
lambda = c/fc;                % 波长
N = 16;                       % 阵列天线数
Btotal = 100e6;               % 总系统带宽 (Hz)
N0 = 1e-11;                   % 噪声功率谱密度 (W/Hz)
Pt = 1;                       % 发射功率 (W)

% 时间模拟参数
T = 50;                       % 总时隙数
eta = 0.5;                    % 初始化频谱占比
eta_track = zeros(1,T);
rate_track = zeros(1,T);
theta_track = zeros(3,T);     % 3个用户角度记录

% 用户初始角度与运动模型（正弦抖动 + 漂移）
theta0 = [-30; 0; 45];        % 初始方位角 (°)
amp = [5; 7; 4];              % 抖动幅度
period = [30; 40; 25];        % 抖动周期

% 初始化阵列
array = phased.ULA('NumElements', N, 'ElementSpacing', lambda/2);
steervec = phased.SteeringVector('SensorArray', array, 'PropagationSpeed', c);

for t = 1:T
    % 用户动态角度更新（模拟移动）
    theta_t = theta0 + amp .* sin(2*pi*t ./ period);  % 当前角度（3x1）
    theta_track(:,t) = theta_t;
    
    % 构建波束权重（多用户导向矢量叠加）
    weights = zeros(N,1);
    for i = 1:length(theta_t)
        ang = [theta_t(i); 0];
        weights = weights + steervec(fc, ang);
    end
    weights = weights / norm(weights);
    
    % 导向矢量与增益
    ang = [theta_t'; zeros(1,length(theta_t))];
    sv = steervec(fc, ang);
    gain = abs(weights' * sv).^2;
    
    % 信噪比与通信速率计算
    SNR = Pt * gain / (N0 * eta * Btotal);
    rate = eta * Btotal * log2(1 + SNR);
    sumRate = sum(rate);
    
    % 记录
    eta_track(t) = eta;
    rate_track(t) = sumRate;
    
    % 简易闭环调节 η（规则：若速率下降且偏低，提升η；否则下降）
    if t > 1
        if sumRate < rate_track(t-1) && sumRate < 3e8 && eta < 0.9
            eta = eta + 0.05;
        elseif sumRate > rate_track(t-1) && eta > 0.2
            eta = eta - 0.05;
        end
    end
end

% 绘图：通信速率演化
figure;
subplot(3,1,1);
plot(1:T, rate_track / 1e6, 'b-o', 'LineWidth', 1.5);
xlabel('时隙 t'); ylabel('通信总速率 (Mbps)');
title('通信速率随时间变化');
grid on;

% 绘图：η变化
subplot(3,1,2);
plot(1:T, eta_track, 'r--s', 'LineWidth', 1.5);
xlabel('时隙 t'); ylabel('频谱占比 η');
title('动态频谱占比调节轨迹');
grid on;

% 绘图：用户平均角度变化
subplot(3,1,3);
plot(1:T, mean(theta_track,1), 'k-x', 'LineWidth', 1.5);
xlabel('时隙 t'); ylabel('用户平均角度 (°)');
title('用户动态运动轨迹（均值）');
grid on;
