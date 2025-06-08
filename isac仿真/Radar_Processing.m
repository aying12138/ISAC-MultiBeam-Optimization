
function targets = Radar_Processing(targets)
% 更新目标位置（简单匀速模型）

for i = 1:length(targets)
    targets(i).pos = targets(i).pos + targets(i).vel;
end
end
