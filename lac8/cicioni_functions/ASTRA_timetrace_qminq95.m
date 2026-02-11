function [qmin,qmin_time,q95,q95time] = ASTRA_timetrace_qminq95(shot)

% ============================================================
% TIMETRACE_QMINQ95
% Loads the ASTRA file corresponding to the selected shot
% and computes qmin(t) and q95(t).
%
% INPUT:
%   shot    TCV shot number
%
% OUTPUT:
%   qmin        minimum safety factor
%   qmin_time   time vector
%   q95         edge safety factor (psi = 0.95)
%   q95time     time vector
%
% Consistent with ASTRA_TCV_summary.m
% ============================================================

%% ----- ASTRA path -----
astra_path = '/Lac8_D/ASTRA/';

pattern = sprintf('*_%d_*.mat',shot);
files = dir(fullfile(astra_path, pattern));

if isempty(files)
    error('No ASTRA file found for shot %d',shot);
end

filename = fullfile(astra_path, files(1).name);
fprintf('Loading ASTRA file: %s\n', files(1).name);

%% ----- Load -----
data = load(filename);
TCV_astra = data;
O = TCV_astra.out;

%% ----- Safety factor -----
Q = 1./O.MU;
time = O.T;
nt = length(time);

%% ===== QMIN (exactly as ASTRA_TCV_summary) =====
qmin = min(Q,[],1);

%% ===== Q95 =====
q95 = NaN(1,nt);

for j = 1:nt
    rho   = O.RHOPSI(:,j);
    qprof = Q(:,j);

    sel = find(isnan(rho) | isnan(qprof));

    if isempty(sel)
        q95(j) = interp1(rho,qprof,sqrt(0.95),'linear');
    else
        q95(j) = NaN;
    end
end

%% ----- remove first timestep (ASTRA initialization) -----
qmin_time = time(2:end);
q95time   = time(2:end);

qmin = qmin(2:end);
q95  = q95(2:end);

end