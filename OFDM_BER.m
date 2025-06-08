
% 高精度通感通信仿真系统（16元阵列 + 动态用户 + OFDM + BER）
% 修正版本：使用 qammod/qamdemod 替代 comm.* 对象，兼容基础 MATLAB 安装

clc; clear; close all;

%% 1. 参数设置
fc = 28e9;                    % 载波频率 (Hz)
c = physconst('LightSpeed');
lambda = c/fc;
N = 16;                       % ULA阵元数
B = 100e6;                    % 带宽 100 MHz
Nsc = 64;                     % 子载波数
Nsym = 100;                  % OFDM符号数（时间长度）
M = 4;                        % 调制阶数：QPSK（4），16QAM（16）
k = log2(M);                  % 每符号比特数
Ncp = Nsc/8;                  % CP长度

userAngles0 = [-30; 0; 45];   % 初始角度
amp = [5; 7; 4];              % 抖动幅度
period = [30; 40; 25];        % 抖动周期
users = length(userAngles0);

Pt = 1; N0 = 1e-11;           % 功率与噪声
eta = 0.5;                    % 初始频谱占比

%% 2. 阵列与工具箱构建
array = phased.ULA('NumElements', N, 'ElementSpacing', lambda/2);
steervec = phased.SteeringVector('SensorArray', array, 'PropagationSpeed', c);

% 初始化结果
BER = zeros(users, Nsym);
SNR_out = zeros(users, Nsym);
eta_track = zeros(1,Nsym);
rate_track = zeros(1,Nsym);
theta_track = zeros(users, Nsym);

%% 3. 主循环：每个 OFDM 符号
for t = 1:Nsym
    % 用户动态角度生成
    theta_t = userAngles0 + amp .* sin(2*pi*t ./ period);
    theta_track(:,t) = theta_t;

    % 构造波束权重（多用户导向矢量叠加）
    weights = zeros(N,1);
    for i = 1:users
        ang = [theta_t(i); 0];
        weights = weights + steervec(fc, ang);
    end
    weights = weights / norm(weights);

    % 每个用户独立调制 & 信道 & 接收
    total_bits = 0; error_bits = 0;
    for i = 1:users
        % 数据生成与调制
        bits = randi([0 1], k*Nsc, 1);
        sym_idx = bi2de(reshape(bits, k, []).','left-msb');  % 映射成符号索引
        sym = qammod(sym_idx, M, 'UnitAveragePower', true);  % QAM调制

        ofdm_tx = ifft(reshape(sym, Nsc, []), Nsc);           % IFFT
        ofdm_tx_cp = [ofdm_tx(end-Ncp+1:end,:); ofdm_tx];     % 加CP

        % 信道增益（方向增益近似）
        sv = steervec(fc, [theta_t(i); 0]);
        gain = abs(weights' * sv)^2;
        snr = Pt * gain / (N0 * eta * B);
        SNR_out(i,t) = snr;

        % 添加高斯噪声
        noise = sqrt(N0/2) * (randn(size(ofdm_tx_cp)) + 1j*randn(size(ofdm_tx_cp)));
        rx = sqrt(Pt*gain) * ofdm_tx_cp + noise;

        % 解调
        rx_no_cp = rx(Ncp+1:end,:);
        sym_rx = fft(rx_no_cp, Nsc);
        sym_rx = sym_rx(:);
        demod_idx = qamdemod(sym_rx, M, 'UnitAveragePower', true, 'OutputType', 'integer');
        demod_bits = de2bi(demod_idx, k, 'left-msb');
        demod_bits = reshape(demod_bits.', [], 1);

        ber = sum(bits ~= demod_bits) / length(bits);
        BER(i,t) = ber;
        total_bits = total_bits + length(bits);
        error_bits = error_bits + sum(bits ~= demod_bits);
    end

    % 总速率估算
    rate_track(t) = eta * B * sum(log2(1 + SNR_out(:,t)));
    eta_track(t) = eta;

    % η闭环调节（简化规则）
    if t > 1
        if rate_track(t) < rate_track(t-1) && eta < 0.9
            eta = eta + 0.05;
        elseif rate_track(t) > rate_track(t-1) && eta > 0.2
            eta = eta - 0.05;
        end
    end
end

%% 4. 绘图
figure;
subplot(3,1,1);
plot(1:Nsym, rate_track/1e6, 'b-o'); grid on;
xlabel('符号'); ylabel('总速率 (Mbps)'); title('通信总速率');

subplot(3,1,2);
plot(1:Nsym, eta_track, 'r--s'); grid on;
xlabel('符号'); ylabel('η'); title('频谱占比变化');

subplot(3,1,3);
plot(1:Nsym, mean(theta_track,1), 'k-x'); grid on;
xlabel('符号'); ylabel('平均角度 (°)'); title('用户平均角度');

figure;
for i = 1:users
    plot(1:Nsym, BER(i,:), '-o'); hold on;
end
grid on; xlabel('符号'); ylabel('BER'); title('各用户误码率');
legend('用户1','用户2','用户3');
