import pandas as pd 
import h5py, sys
import re
import numpy as np 
import matplotlib
#matplotlib.use('Agg') # set the backend before importing pyplot
import matplotlib.pyplot as plt
plt.rcParams['lines.linewidth'] = 0.8

machine = 'TCV'
shot_number = str(64770)
base_dir = 'C:\\Users\\cicioni\\Documents\\elm_dynamics\\'
shot_name=machine + 'no' + shot_number
parquet_path = base_dir+"TCV_{}_apau_labeled.parquet".format(shot_number) #reading .parquet file
df_parquet = pd.read_parquet(parquet_path)
h5_file = h5py.File(base_dir+shot_name+'.h5', 'r')

elm_trigger=[]
#creo elm_trigger
elm_label = df_parquet["ELM_label"].values
#elm_label = np.array([0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1])    
times=df_parquet["time"].values
control_variable = False
for i in elm_label:
    if i == 1 and not control_variable:
        elm_trigger.append(1)
        control_variable = True
    elif i==0:
        elm_trigger.append(0)
        control_variable = False
    else:
        elm_trigger.append(0)


# Numero di elementi per finestra e passo
window_size = 200  # Numero di elementi in una finestra
step_size = 200    # Numero di elementi per ogni passo

# Calcolo della frequenza degli eventi
frequenze = []
centri_temporali = []

# Scansione del segnale con una finestra mobile
for start in range(0, len(elm_trigger) - window_size + 1, step_size):
    end = start + window_size
    finestra_trigger = elm_trigger[start:end]  # Estraggo la finestra
    finestra_tempo = times[start:end]       # Finestra corrispondente di tempo
    
    # Calcolo della frequenza degli eventi
    eventi_nella_finestra = np.sum(finestra_trigger)  # Conteggio trigger (1)
    durata_finestra = finestra_tempo[-1] - finestra_tempo[0]  # Durata finestra
    
    frequenza = eventi_nella_finestra / durata_finestra if durata_finestra > 0 else 0
    frequenze.append(frequenza)
    
    # Calcolo del centro temporale della finestra
    centro = (finestra_tempo[0] + finestra_tempo[-1]) / 2
    centri_temporali.append(centro)

# Plot della frequenza in funzione del tempo
plt.figure(figsize=(10, 5))
plt.plot(centri_temporali, frequenze, marker='o', linestyle='-', color='b', label='Frequency')
plt.xlabel('time (s)')
plt.ylabel('Frequency (Hz)')
#plt.title('Frequenza degli eventi in funzione del tempo')
plt.grid(True)
plt.legend()
plt.show()

sig = h5_file['SIG']['Halpha13']['signal']