function plot_timetrace_ip_fit(shot,timeWindow)

% ============================================================
% PLOT_TIMETRACE_IP_FIT
% Calls timetrace_ip_fit and produces the diagnostic plot.
%
% INPUT:
%   shot        TCV shot number
%   timeWindow  [tmin tmax] time interval
% ============================================================

[tIp,Ip_filt,elmTimes,Ip_elm,t_slopeIp,slopeIp,t_fit,Ip_fit] = ...
    timetrace_ip_fit(shot,timeWindow);

%% ----- Plot -----
figure('Color','w'); hold on;

plot(tIp,Ip_filt,'k','LineWidth',1.5)
plot(elmTimes,Ip_elm,'ro','MarkerFaceColor','r')
plot(t_fit,Ip_fit,'m','LineWidth',2)
xline(t_slopeIp,'k--','LineWidth',1.5)

xlabel('Time [s]')
ylabel('I_p [kA]')
title(sprintf('Shot %d — Plasma current slope fit',shot))
grid on

legend('Ip filtered','Ip @ ELM','3-region fit','t_{slope}','Location','best')

end