function elmTimes = get_elm_times(machine, shot, dir_elm)
    pq_name = sprintf('%s_%d_cicioni_labeled.parquet', machine, shot);
    DB = parquet_DB(machine, shot);
    try
        T = DB.pq_read(shot, 'read_dir', dir_elm, 'pq_name', pq_name);
    catch
        error('Missing parquet file: %s', pq_name);
    end
    if isempty(T)
        if ~isempty(DB.pq_labels)
            T = DB.pq_labels;
        elseif ~isempty(DB.pq_data)
            T = DB.pq_data;
        else
            error('pq_read returned empty data');
        end
    end
    elmTimes = T.time(T.ELM_label == 1);
end