function plot_timetrace_shear(shot,rhoRange)

% ============================================================
% PLOT_TIMETRACE_SHEAR
% Plots the time evolution of the magnetic shear averaged
% over a radial interval.
%
% INPUT:
%   shot      TCV shot number
%   rhoRange  [rho_min rho_max] (optional)
% ============================================================

if nargin < 2
    rhoRange = [0.7 0.85];
end

[shear_mean,time] = ASTRA_timetrace_shear(shot,rhoRange);

figure('Color','w');
plot(time,shear_mean,'LineWidth',2)

xlabel('Time [s]')
ylabel('<s>  (magnetic shear)')
title(sprintf('Shot %d — average magnetic shear %.2f < \\rho < %.2f',...
    shot,rhoRange(1),rhoRange(2)))

grid on
box on

end