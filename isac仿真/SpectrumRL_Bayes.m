
function eta = SpectrumRL_Bayes(eta, Pd, rate)
% 贝叶斯频谱调节（简化策略）
% 若感知性能不达标 → η↑，否则 η↓

if Pd < 0.8
    eta = min(1, eta + 0.05);
elseif rate < 2e8
    eta = min(1, eta + 0.03);
else
    eta = max(0.2, eta - 0.02);
end
end
