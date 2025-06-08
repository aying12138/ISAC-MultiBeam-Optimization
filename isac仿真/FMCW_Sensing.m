
function [Pd, ranges, snr] = FMCW_Sensing(config, targets, weights)
% 模拟FMCW感知过程，输出检测概率Pd、目标距离与SNR

c = config.c;
fc = config.fc;
lambda = config.lambda;
Pt = config.Pt;
B = config.B;
eta = config.eta;
N0 = config.N0;

sv = phased.SteeringVector('SensorArray', config.array, ...
    'PropagationSpeed', c);

Pd = zeros(1, length(targets));
ranges = zeros(1, length(targets));
snr = zeros(1, length(targets));

for i = 1:length(targets)
    tgt = targets(i);
    R = norm(tgt.pos);
    ranges(i) = R;

    G = abs(weights' * sv(fc, [tgt.angle; 0]))^2;
    sigma = tgt.rcs;

    Pr = (Pt * G^2 * lambda^2 * sigma) / ((4*pi)^3 * R^4);
    Pn = N0 * (1 - eta) * B;
    snr_val = Pr / Pn;
    snr(i) = snr_val;

    Pd(i) = 1 - exp(-1e-10 * snr_val);
end
end
