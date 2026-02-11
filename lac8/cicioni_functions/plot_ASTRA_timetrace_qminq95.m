function plot_ASTRA_timetrace_qminq95(shot)

% ============================================================
% PLOT_TIMETRACE_QMINQ95
% Calls timetrace_qminq95 and produces the diagnostic plot.
%
% INPUT:
%   shot    TCV shot number
% ============================================================

[qmin,tmin,q95,t95] = ASTRA_timetrace_qminq95(shot);

figure('Color','w','Name',sprintf('Shot %d - q time traces',shot));

% ---- qmin ----
subplot(2,1,1)
plot(tmin,qmin,'LineWidth',2)
grid on
box on
ylabel('q_{min}')
title(sprintf('Shot %d : ASTRA minimum safety factor q_{min}',shot))
xlim([tmin(1) tmin(end)])

% ---- q95 ----
subplot(2,1,2)
plot(t95,q95,'LineWidth',2)
grid on
box on
ylabel('q_{95}')
xlabel('Time [s]')
title('ASTRA edge safety factor q_{95}')
xlim([t95(1) t95(end)])

end