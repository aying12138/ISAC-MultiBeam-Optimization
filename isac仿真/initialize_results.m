
function results = initialize_results(config)
% 初始化记录结构体

U = config.userParam.numUsers;
T = config.simParam.T;
N = config.Narray;

results.eta = zeros(1,T);
results.sumRate = zeros(1,T);
results.userRates = zeros(U, T);
results.BER = zeros(U, T);
results.SNR = zeros(U, T);
results.theta = zeros(U, T);
results.weights = zeros(N, T);
end
