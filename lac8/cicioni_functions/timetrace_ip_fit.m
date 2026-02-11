function [tIp,Ip_filt,elmTimes,Ip_elm,t_slopeIp,slopeIp,t_fit,Ip_fit] = timetrace_ip_fit(shot,timeWindow)

% ============================================================
% TIMETRACE_IP_FIT
% Computes filtered plasma current Ip and its 3–region slope fit.
%
% INPUT:
%   shot        TCV shot number
%   timeWindow  [tmin tmax] time interval for the analysis
%
% OUTPUT:
%   tIp        time vector of filtered Ip
%   Ip_filt    filtered plasma current
%   elmTimes   ELM occurrence times
%   Ip_elm     Ip sampled at ELM times
%   t_slopeIp  start time of current ramp
%   slopeIp    slope of the ramp (kA/s)
%   t_fit      time vector of fitted function
%   Ip_fit     fitted piecewise function
% ============================================================

%% ----- Data access -----
HH = DATA('TCV');
dir_elm = '/home/cicioni/defuse/DEFUSE_Events/Tables/Validated/';

[Ip, tIp] = HH.get_data('IPLA', shot, 'verb', 0);
Ip = -Ip*1e-3; % convert to kA

%% ----- ELM times -----
elmTimes = get_elm_times('TCV',shot,dir_elm);

%% ----- Time window -----
tmin = timeWindow(1);
tmax = timeWindow(2);

sel = tIp>=tmin & tIp<=tmax;
tIp = tIp(sel);
Ip  = Ip(sel);

elmTimes = elmTimes(elmTimes>=tmin & elmTimes<=tmax);

%% ----- Mean ELM period -----
T_ELM = mean(diff(elmTimes));

%% ----- Sampling frequency -----
fsIp = 1/mean(diff(tIp));

%% ----- Self-consistent filtering -----
Nmed = round(T_ELM*fsIp);
Nmed = max(3,2*floor(Nmed/2)+1);

Ip_med  = medfilt1(Ip,Nmed);
Ip_filt = lowpass(Ip_med,50,fsIp);

%% ----- Sample Ip at ELMs -----
Ip_elm = interp1(tIp,Ip_filt,elmTimes,'linear','extrap');

t = elmTimes(:);
y = Ip_elm(:);
N = numel(t);

%% ----- 3-region piecewise fit -----
err_min = inf;
best = [];

for i1 = 2:N-3
    for i2 = i1+2:N-1

        p = polyfit(t(i1:i2),y(i1:i2),1);
        m = p(1);
        q = p(2);

        a = m*t(i1)+q;
        b = m*t(i2)+q;

        y_fit = zeros(size(y));
        y_fit(t<=t(i1)) = a;
        y_fit(t>t(i1)&t<t(i2)) = m*t(t>t(i1)&t<t(i2))+q;
        y_fit(t>=t(i2)) = b;

        err = mean((y-y_fit).^2);

        if err<err_min
            err_min = err;
            best = struct('i1',i1,'i2',i2,'a',a,'b',b,'m',m,'q',q);
        end
    end
end

%% ----- Physical parameters -----
t_slopeIp = t(best.i1);
slopeIp   = best.m;

%% ----- Continuous fitted function -----
t_fit = linspace(min(tIp),max(tIp),400);
Ip_fit = zeros(size(t_fit));

Ip_fit(t_fit<=t_slopeIp)=best.a;

sel = t_fit>t_slopeIp & t_fit<t(best.i2);
Ip_fit(sel)=best.m*t_fit(sel)+best.q;

Ip_fit(t_fit>=t(best.i2))=best.b;

end