
function targets = Target_Model()
% 生成多个目标，含位置、速度、RCS、角度

targets(1).pos = [100; 0];
targets(1).vel = [1; 0];
targets(1).rcs = 10;
targets(1).angle = 10;

targets(2).pos = [200; -50];
targets(2).vel = [-1; 1];
targets(2).rcs = 5;
targets(2).angle = -20;

targets(3).pos = [150; 100];
targets(3).vel = [0.5; -0.5];
targets(3).rcs = 8;
targets(3).angle = 30;
end
