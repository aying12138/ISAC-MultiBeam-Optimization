
function plot_ISAC_results(results, config)
% 绘图：结果可视化

T = config.simParam.T;
t = 1:T;

figure;
subplot(3,1,1);
plot(t, results.sumRate/1e6, 'b-', 'LineWidth', 2);
xlabel('时隙'); ylabel('总速率 (Mbps)'); title('通信总速率');
grid on;

subplot(3,1,2);
plot(t, results.eta, 'r--', 'LineWidth', 2);
xlabel('时隙'); ylabel('\eta'); title('频谱占比变化');
grid on;

subplot(3,1,3);
plot(t, mean(results.theta,1), 'k-x', 'LineWidth', 2);
xlabel('时隙'); ylabel('平均用户角度 (°)'); title('用户动态轨迹');
grid on;
end
