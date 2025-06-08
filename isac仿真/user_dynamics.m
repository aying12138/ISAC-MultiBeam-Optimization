
function theta = user_dynamics(userParam, t)
% 模拟用户动态角度（正弦波漂移）
theta = userParam.angles0 + ...
        userParam.amp .* sin(2*pi*t ./ userParam.period);
end
