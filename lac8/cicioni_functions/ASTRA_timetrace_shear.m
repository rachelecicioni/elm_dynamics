function [shear_mean,time] = ASTRA_timetrace_shear(shot,rhoRange)

% ============================================================
% TIMETRACE_SHEAR
% Computes the time evolution of the average magnetic shear
% in a given radial interval.
%
% INPUT:
%   shot      TCV shot number
%   rhoRange  [rho_min rho_max] (e.g. [0.7 0.85])
%
% OUTPUT:
%   shear_mean   average shear in the radial interval
%   time         time vector
% ============================================================

if nargin < 2
    rhoRange = [0.7 0.85];
end

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

SHEAR = O.SHEAR;     % (rho,time)
RHO   = O.RHOPSI;    % normalized radial coordinate
time  = O.T;

nt = length(time);
shear_mean = NaN(1,nt);

rho_min = rhoRange(1);
rho_max = rhoRange(2);

%% ----- radial average -----
for j = 1:nt

    rho_j   = RHO(:,j);
    shear_j = SHEAR(:,j);

    % valid points
    valid = ~isnan(rho_j) & ~isnan(shear_j);

    if sum(valid) < 5
        continue
    end

    rho_j   = rho_j(valid);
    shear_j = shear_j(valid);

    % select radial interval
    sel = rho_j >= rho_min & rho_j <= rho_max;

    if any(sel)
        shear_mean(j) = mean(shear_j(sel));
    else
        shear_mean(j) = NaN;
    end

end

%% remove ASTRA first timestep
time = time(2:end);
shear_mean = shear_mean(2:end);

end