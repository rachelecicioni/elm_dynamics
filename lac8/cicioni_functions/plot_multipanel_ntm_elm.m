function plot_multipanel_ntm_elm(shot, timeWindow)

    % === DB & data access ===
    sqlDb = SQL_db('TCV');
    sqlDb.authenticate_from_file();
    [structDB, ~] = sqlDb.fetchDB();

    tokamak = 'TCV';
    dir_elm = '/home/cicioni/defuse/DEFUSE_Events/Tables/Validated/';
    HH = DATA(tokamak);

    % === ELM times ===
    try
        elmTimes = get_elm_times(tokamak, shot, dir_elm);
        fprintf('Shot %d: %d ELMs found\n', shot, numel(elmTimes));
    catch
        elmTimes = [];
    end

    % === NTM onset ===
    ntmTime = [];
    shotField = sprintf('no%d', shot);
    if isfield(structDB, shotField)
        evt = structDB.(shotField).Events;
        if isfield(evt,'MHD_N1') && ~isempty(evt.MHD_N1.time)
            ntmTime = evt.MHD_N1.time(1);
            fprintf('Shot %d: NTM onset at %.3f s\n', shot, ntmTime);
        end
    end

    % === Time window ===
    if nargin < 2 || isempty(timeWindow)
        [~, t_all] = HH.get_data('BETAN', shot, 'verb', 0);
        timeWindow = [min(t_all) max(t_all)];
    end

    timeWindow = sort(timeWindow);

    % === Figure ===
    figure('Color','w','Units','normalized','Position',[0.05 0.07 0.9 0.86]);
    tl = tiledlayout(4,3,'TileSpacing','compact','Padding','compact');
    title(tl, sprintf('TCV %d — multipanel', shot));

    ax = gobjects(12,1);

    %% =======================
    % COLUMN 1
    %% =======================

    % (1,1) IPLA
    ax(1) = nexttile(1);
    [y,t] = HH.get_data('IPLA',shot,'verb',0);
    plot(t,-y*1e-3,'LineWidth',1); grid on;
    ylabel('I_P (kA)'); title('I_P');
    xlim(timeWindow);
    ylim([0 350]);

    % (2,1) PNBI + PECRH
    ax(4) = nexttile(4);
    hold on;
    [pnbi,tp] = HH.get_data('PNBI',shot,'verb',0);
    [pecrh,te] = HH.get_data('PECRH',shot,'verb',0);
    plot(tp,pnbi,'LineWidth',1);
    plot(te,pecrh,'LineWidth',1);
    hold off; grid on;
    title('PNBI / PECRH'); ylabel('Power (MW)');
    xlim(timeWindow);
    ylim([0 1.5]);

    % (3,1) DELTA_TOP / DELTA_BOTTOM / mean
    ax(7) = nexttile(7);
    hold on;
    [dt,tt] = HH.get_data('DELTA_TOP',shot,'verb',0);
    [db,tb] = HH.get_data('DELTA_BOTTOM',shot,'verb',0);
    t_common = tt;
    dmean = 0.5*(dt + db);
    plot(tt,dt,'LineWidth',1);
    plot(tb,db,'LineWidth',1);
    plot(t_common,dmean,'k--','LineWidth',1.3);
    hold off; grid on;
    title('\delta TOP / BOTTOM / mean');
    ylabel('\delta');
    xlim(timeWindow);
    ylim([-0.2 0.8]);

    % (4,1) Q95
    ax(10) = nexttile(10);
    [y,t] = HH.get_data('Q95',shot,'verb',0);
    plot(t,y,'LineWidth',1); grid on;
    ylabel('Q95'); title('Q95');
    xlim(timeWindow);
    ylim([0 10]);

    %% =======================
    % COLUMN 2
    %% =======================

    % (1,2) BETAN
    ax(2) = nexttile(2);
    [y,t] = HH.get_data('BETAN',shot,'verb',0);
    plot(t,y,'LineWidth',1); grid on;
    title('\beta_N'); ylabel('\beta_N');
    xlim(timeWindow);
    ylim([0 3]);

    % (2,2) N1_RMS
    ax(5) = nexttile(5);
    [y,t] = HH.get_data('N1_RMS',shot,'verb',0);
    plot(t,y,'LineWidth',1); grid on;
    title('N1 RMS'); ylabel('N1 RMS');
    xlim(timeWindow);

    % (3,2) KAPPA
    ax(8) = nexttile(8);
    [y,t] = HH.get_data('KAPPA',shot,'verb',0);
    plot(t,y,'LineWidth',1); grid on;
    title('\kappa'); ylabel('\kappa');
    xlim(timeWindow);
    ylim([0 2]);

    % (4,2) q0
    ax(11) = nexttile(11);
    [y,t] = HH.get_data('Q0',shot,'verb',0);
    plot(t,y,'LineWidth',1); grid on;
    title('q_0'); ylabel('q_0');
    xlim(timeWindow);
    ylim([0 4]);

    %% =======================
    % COLUMN 3
    %% =======================

    % (1,3) GWfr
    ax(3) = nexttile(3);
    [y,t] = HH.get_data('GWfr',shot,'verb',0);
    plot(t,y,'LineWidth',1); grid on;
    title('GWfr'); ylabel('GWfr');
    xlim(timeWindow);
    ylim([0 1]);

    % (2,3) Wtot
    ax(6) = nexttile(6);
    [y,t] = HH.get_data('Wtot',shot,'verb',0);
    plot(t,y,'LineWidth',1); grid on;
    title('W_{tot} (J)'); ylabel('W_{tot}');
    xlim(timeWindow);
    ylim([0 3*1e4]);

    % (3,3) gas valves
    ax(9) = nexttile(9);
    gas = gdat(shot,'gas_valve');
    plot(gas.t, gas.data(:,1),'LineWidth',1); hold on;
    if size(gas.data,2)>1
        plot(gas.t, gas.data(:,2),'LineWidth',1);
    end
    hold off; grid on;
    title('Gas valves'); ylabel('Valve');
    xlim(timeWindow);
    ylim([0 15*1e20]);

    % (4,3) Halpha13
    ax(12) = nexttile(12);
    [y,t] = HH.get_data('Halpha13',shot,'verb',0);
    plot(t,y,'LineWidth',1); grid on;
    title('H\alpha_{13}');
    ylabel('a.u.');
    xlim(timeWindow);

    %% === Event lines ===
    if ~isempty(elmTimes)
        draw_elm_vlines(ax, elmTimes);
    end
    if ~isempty(ntmTime)
        draw_ntm_vline(ax, ntmTime);
    end

    datacursormode on;
    
    %% === Salvataggio automatico in PDF ===
    saveDir = '/home/cicioni/defuse/cicioni_files/shots_plot';
    if ~exist(saveDir,'dir')
        mkdir(saveDir); % crea la cartella se non esiste
    end

    % Nome file: <shot>_multipanel.pdf
    saveFile = fullfile(saveDir, sprintf('%d_multipanel.pdf', shot));

    % Imposta dimensione pagina corretta
    set(gcf,'PaperPositionMode','auto');

    % Salva il PDF, sovrascrivendo se esiste
    exportgraphics(gcf, saveFile, 'ContentType','vector');

    fprintf('Figure salvata in PDF: %s\n', saveFile);
end


function draw_elm_vlines(axArray, elmTimes)
    for a = reshape(axArray,1,[])
        if isgraphics(a)
            hold(a,'on');
            xline(a, elmTimes, '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 0.5);
            hold(a,'off');
        end
    end
end

function draw_ntm_vline(axArray, ntmTime)
    for a = reshape(axArray,1,[])
        if isgraphics(a)
            hold(a,'on');
            xline(a, ntmTime, '--r', 'LineWidth', 1.2, ...
                'Label', 'NTM onset', 'LabelOrientation','horizontal', ...
                'LabelVerticalAlignment','bottom');
            hold(a,'off');
        end
    end
end