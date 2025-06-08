
% ISAC_Main.m
% 主入口：ISAC系统仿真主程序

clc; clear; close all;

%% 参数设置
config = get_ISAC_config();  % 获取系统参数结构体

%% 初始化记录结构体
results = initialize_results(config);

%% 主仿真循环
for t = 1:config.simParam.T
    fprintf("=== 仿真时隙 %d/%d ===\n", t, config.simParam.T);

    % 用户角度更新
    theta = user_dynamics(config.userParam, t);
    results.theta(:, t) = theta;

    % 波束权重计算
    weights = calc_beam_weights(config.array, config.fc, theta);
    results.weights(:, t) = weights;

    % 通信性能仿真 (OFDM链路)
    [rate, ber, snr] = OFDM_Link(config, theta, weights);
    results.sumRate(t) = sum(rate);
    results.userRates(:,t) = rate;
    results.BER(:,t) = ber;
    results.SNR(:,t) = snr;

    % 频谱调节（示例规则）
    if t > 1 && mean(ber) > 0.1
        config.eta = min(1, config.eta + 0.05);
    elseif t > 1
        config.eta = max(0.2, config.eta - 0.03);
    end
    results.eta(t) = config.eta;
end

%% 保存结果
save('ISAC_Simulation_Results.mat', 'results');

%% 绘图
plot_ISAC_results(results, config);

