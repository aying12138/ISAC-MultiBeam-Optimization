
function weights = calc_beam_weights(array, fc, theta)
% 多用户导向矢量叠加形成复合波束
sv = phased.SteeringVector('SensorArray', array, ...
    'PropagationSpeed', physconst('LightSpeed'));
weights = zeros(array.NumElements, 1);
for i = 1:length(theta)
    ang = [theta(i); 0];
    weights = weights + sv(fc, ang);
end
weights = weights / norm(weights);
end
