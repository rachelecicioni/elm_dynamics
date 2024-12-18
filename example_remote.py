import os
import pyarrow.parquet as pq
import pandas as pd
import matplotlib.pyplot as plt


# read .json TCV_db structure
df_TCV_db = pd.read_json('TCV_db.json')

# read .parquet table
df_Table_DATA = pq.read_table('TCV_DATAno57093.parquet')

# plot PhotoDiode signal for ELMs visualization
time = df_Table_DATA[df_Table_DATA.column_names.index('time')]
PD = df_Table_DATA[df_Table_DATA.column_names.index('PD')]
fig, ax = plt.subplots()
ax.plot(time, PD, 'k')
plt.xlabel('Time [s]')
plt.ylabel('Dalpha emission from PhotoDiode [V]')

# get Events from TCV_db structure
Events = df_TCV_db.no57093.Events

# get ELM times
ELM_times = Events['ELM']['time']

# get closer
elm = []
df_DATA = df_Table_DATA.to_pandas()
for jj in range(len(ELM_times)):
    elm.append(df_DATA['time'].sub(ELM_times[jj]).abs().idxmin())
PD_ELMs = df_Table_DATA['PD'].to_pandas()
ELM_values = PD_ELMs[elm]

# plot ELM events
ax.scatter(ELM_times, ELM_values, facecolors='None', edgecolors='r')
plt.show()
