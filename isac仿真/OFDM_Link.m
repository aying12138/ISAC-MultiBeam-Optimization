
function [rate, ber, snr] = OFDM_Link(config, theta, weights)
% OFDM链路仿真

U = config.userParam.numUsers;
rate = zeros(U,1); ber = zeros(U,1); snr = zeros(U,1);

sv = phased.SteeringVector('SensorArray', config.array, ...
    'PropagationSpeed', config.c);

for u = 1:U
    bits = randi([0 1], config.k * config.Nsc, 1);
    sym_idx = bi2de(reshape(bits, config.k, []).', 'left-msb');
    sym = qammod(sym_idx, config.M, 'UnitAveragePower', true);

    tx = ifft(reshape(sym, config.Nsc, []), config.Nsc);
    tx_cp = [tx(end-config.Ncp+1:end,:); tx];

    ang = [theta(u); 0];
    steer = sv(config.fc, ang);
    gain = abs(weights' * steer)^2;

    snr_val = config.Pt * gain / (config.N0 * config.eta * config.B);
    snr(u) = snr_val;

    noise = sqrt(config.N0/2) * (randn(size(tx_cp)) + 1j*randn(size(tx_cp)));
    rx = sqrt(config.Pt * gain) * tx_cp + noise;

    rx = rx(config.Ncp+1:end,:);
    sym_rx = fft(rx, config.Nsc); sym_rx = sym_rx(:);

    demod_idx = qamdemod(sym_rx, config.M, 'UnitAveragePower', true, ...
                         'OutputType', 'integer');
    bits_rx = de2bi(demod_idx, config.k, 'left-msb');
    bits_rx = reshape(bits_rx.', [], 1);

    ber(u) = sum(bits_rx ~= bits) / length(bits);
    rate(u) = config.eta * config.B * log2(1 + snr_val);
end
end
