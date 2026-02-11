function multipanel_ipq(shot,timeWindow,structDB)

% ============================================================
% Multiplot plasma dynamics summary
% Adds:
%   - vertical grey lines at ELMs
%   - NTM onset marker
% ============================================================

tmin = timeWindow(1);
tmax = timeWindow(2);



%% ===================== CURRENT =====================
[tIp,Ip_filt,~,~,t_slopeIp,~,t_fit,Ip_fit] = ...
    timetrace_ip_fit(shot,timeWindow);

%% ===================== Q PROFILE ===================
[qmin,tqmin,q95,tq95] = ASTRA_timetrace_qminq95(shot);

sel = tqmin>=tmin & tqmin<=tmax;
tqmin=tqmin(sel); qmin=qmin(sel);

sel = tq95>=tmin & tq95<=tmax;
tq95=tq95(sel); q95=q95(sel);

%% ===================== SHEAR =======================
[shear,t_shear] = ASTRA_timetrace_shear(shot,[0.7 0.85]);
sel = t_shear>=tmin & t_shear<=tmax;
t_shear=t_shear(sel); shear=shear(sel);

%% ===================== ELM TIMES ===================
dir_elm = '/home/cicioni/defuse/DEFUSE_Events/Tables/Validated/';
elmTimes = get_elm_times('TCV',shot,dir_elm);
elmTimes = elmTimes(elmTimes>=tmin & elmTimes<=tmax);
T_ELM = diff(elmTimes);

%% ===================== NTM ONSET ===================
% === DB & data access ===
sqlDb = SQL_db('TCV');
sqlDb.authenticate_from_file();
[structDB, ~] = sqlDb.fetchDB();
    
ntmTime = [];
shotField = sprintf('no%d', shot);
if isfield(structDB, shotField)
    evt = structDB.(shotField).Events;
    if isfield(evt,'MHD_N1') && ~isempty(evt.MHD_N1.time)
        ntmTime = evt.MHD_N1.time(1);
        fprintf('Shot %d: NTM onset at %.3f s\n', shot, ntmTime);
    end
end

%% ===================== FIGURE ======================
figure('Color','w','Position',[200 50 850 1000]);

tl = tiledlayout(6,1,'TileSpacing','compact','Padding','compact');
ax = gobjects(6,1);

%% 1) CURRENT
ax(1)=nexttile; hold on
plot(tIp,Ip_filt,'k','LineWidth',1.4)
plot(t_fit,Ip_fit,'m','LineWidth',2)
xline(t_slopeIp,'k--','LineWidth',1.5)
ylabel('I_p [kA]')
title(sprintf('Shot %d summary',shot))
grid on
xlim([tmin tmax])

%% 2) QMIN
ax(2)=nexttile; hold on
plot(tqmin,qmin,'b','LineWidth',1.5)
ylabel('q_{min}')
grid on
xlim([tmin tmax])

%% 3) Q95
ax(3)=nexttile; hold on
plot(tq95,q95,'r','LineWidth',1.5)
ylabel('q_{95}')
grid on
xlim([tmin tmax])

%% 4) SHEAR
ax(4)=nexttile; hold on
plot(t_shear,shear,'Color',[0 0.6 0],'LineWidth',1.5)
ylabel('<s>')
grid on
xlim([tmin tmax])

%% 5) ELM PERIOD
ax(5)=nexttile; hold on

for i=1:length(T_ELM)
    t1=elmTimes(i);
    t2=elmTimes(i+1);
    T=T_ELM(i);
    plot([t1 t2],[T T]*1e3,'k','LineWidth',2)
end

ylabel('T_{ELM} [ms]')
xlabel('Time [s]')
grid on
xlim([tmin tmax])

%% 6) N1 RMS
ax(6)=nexttile; hold on

HH = DATA('TCV');
[y,t] = HH.get_data('N1_RMS',shot,'verb',0);

% selezione finestra
sel = t>=tmin & t<=tmax;
t = t(sel);
y = y(sel);

plot(t,y,'LineWidth',1.2)

ylabel('N1 RMS')
title('N1 RMS amplitude')
grid on
xlim([tmin tmax])

%% ===================== ELM VERTICAL LINES =====================
for a = reshape(ax,1,[])
    hold(a,'on');
    for e = 1:length(elmTimes)
        xline(a,elmTimes(e),'k','LineWidth',0.5);
    end
end

%% ===================== NTM ONSET LINE ========================
if ~isempty(ntmTime)
    draw_ntm_vline(ax,ntmTime);
end

%% LINK AXES
linkaxes(ax,'x')

%% ===================== SAVE FIGURE =====================
saveDir = '/home/cicioni/defuse/cicioni_files/shots_plot';

% crea la cartella se non esiste
if ~exist(saveDir,'dir')
    mkdir(saveDir);
end

filename = fullfile(saveDir, sprintf('%d_multipanel_ipq.pdf',shot));

exportgraphics(gcf, filename, 'ContentType','vector');

fprintf('Figure saved in: %s\n', filename);

end