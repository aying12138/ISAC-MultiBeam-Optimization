
function tracks = KalmanTracker(tracks, observations)
% 使用 Kalman 滤波器更新目标状态
% 输入 tracks: 上一帧跟踪器结构体数组
% 输入 observations: 当前帧目标坐标（Nx2）

dt = 1;
F = [1 0 dt 0; 0 1 0 dt; 0 0 1 0; 0 0 0 1];
H = [1 0 0 0; 0 1 0 0];
Q = 0.01 * eye(4);
R = 1 * eye(2);

if isempty(tracks)
    for i = 1:size(observations,1)
        tracks(i).x = [observations(i,1); observations(i,2); 0; 0];
        tracks(i).P = eye(4);
    end
else
    for i = 1:length(tracks)
        % 预测
        tracks(i).x = F * tracks(i).x;
        tracks(i).P = F * tracks(i).P * F' + Q;

        % 更新
        z = observations(i,:)';
        y = z - H * tracks(i).x;
        S = H * tracks(i).P * H' + R;
        K = tracks(i).P * H' / S;

        tracks(i).x = tracks(i).x + K * y;
        tracks(i).P = (eye(4) - K * H) * tracks(i).P;
    end
end
end
