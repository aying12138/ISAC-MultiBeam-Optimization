
function config = get_ISAC_config()
% 获取 ISAC 系统参数配置

% 通信参数
config.fc = 28e9;
config.c = physconst('LightSpeed');
config.lambda = config.c / config.fc;
config.Narray = 16;
config.B = 100e6;
config.N0 = 1e-11;
config.Pt = 1;
config.eta = 0.5;

% OFDM参数
config.Nsc = 64;
config.Ncp = config.Nsc / 8;
config.M = 16;
config.k = log2(config.M);

% 用户参数
config.userParam.numUsers = 3;
config.userParam.angles0 = [-30, 0, 45];
config.userParam.amp = [5, 7, 4];
config.userParam.period = [30, 40, 25];

% 仿真参数
config.simParam.T = 50;

% 创建阵列对象
config.array = phased.ULA('NumElements', config.Narray, ...
                          'ElementSpacing', config.lambda/2);
end
